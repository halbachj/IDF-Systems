import argparse
import glob
import csv
import logging
import os
from datetime import datetime

import pandas as pd


# Create a logger
logger = logging.getLogger("csv_formatter_logger")


def setup_logger():
    logger.setLevel(logging.DEBUG)  # Set the minimum level to log

    # Create a file handler
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    file_handler = logging.FileHandler(f"csv_reformater_{timestamp}.log")
    file_handler.setLevel(logging.INFO)  # Log everything to the file

    # Create a console (stdout) handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.DEBUG)  # Only log INFO and above to stdout

    # Define a formatter
    formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

    # Apply the formatter to both handlers
    file_handler.setFormatter(formatter)
    console_handler.setFormatter(formatter)

    # Add handlers to the logger
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)


class ResultDataSet:
    def __init__(self, path: str):
        """Initialize the object and read the CSV file."""
        self.path = path
        self.model_settings = {}  # Stores named tables from model settings
        self.plots = {}  # Stores plot-related tables
        self._read_csv(path)
        self._clean_data_frames()
        self._reorganize_data()
        #logger.debug(f"CSV formatter read complete.\n{self.plots["plot_1"][2].head()}")

    def _read_csv(self, path):
        """Reads the CSV file and extracts tables."""
        with open(path, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)

            current_section = None
            current_data = []
            in_model_settings = True
            current_plot = None
            plot_stage = 0  # 0: Plot Metadata, 1: Graph Descriptions, 2: Graph Data

            self.header = reader.__next__()
            self.file_name = reader.__next__()
            self.time = reader.__next__()

            for row in reader:
                if not row:
                    continue  # Skip empty rows

                if len(row) == 1:  # New section or plot name
                    section_name = row[0].strip('"')

                    # Save previous table
                    if current_section and current_data:
                        self._store_table(current_section, current_data, in_model_settings, current_plot, plot_stage)

                    # Transition from model settings to plots
                    if in_model_settings and section_name != "MODEL SETTINGS":
                        in_model_settings = False
                        plot_stage = 0

                    if not in_model_settings:
                        current_plot = section_name
                        self.plots[current_plot] = {}
                        plot_stage = 0
                    else:
                        current_section = section_name

                    current_data = []
                    continue

                # Transition between plot tables
                if not in_model_settings and plot_stage < 2:
                    if len(current_data) > 1 and len(current_data[0]) != len(row):
                        self._store_table(current_plot, current_data, in_model_settings, current_plot, plot_stage)
                        current_data = []
                        plot_stage += 1

                # Fix malformed multi-index header for Graph Data
                if not in_model_settings and plot_stage == 2 and not current_data:
                    next_row = next(reader, [])
                    if next_row and len(next_row) > len(row):
                        row = self._fix_multiindex_header(row, next_row)
                        current_data.append(row)
                        row = next_row
                current_data.append(row)
            # Save the last processed table
            if current_plot and current_data and plot_stage==2:
                self._store_table(current_plot, current_data, in_model_settings, current_plot, plot_stage, True)

    def _reorganize_data(self):
        for i, (k, plot) in enumerate(self.plots.items()):
            data = plot[2].stack(level=0, future_stack=True)
            data = data.iloc[data.index.get_level_values(1).argsort(kind='stable')]
            data.index.names = ["index", "course"]
            data.drop(columns=["color", "pen down?"], inplace=True)
            data.rename(columns={"x": "ticks", "y": "happy"}, inplace=True)
            #logger.debug(data.index)
            plot[3] = data

    def _store_table(self, name, data, in_model_settings, plot_name=None, plot_stage=None, multi_index=False):
        """Converts a parsed table into a DataFrame and stores it."""

        df = pd.DataFrame(data[1:], columns=data[0])
        if multi_index:
            df.columns = pd.MultiIndex.from_tuples(zip(df.columns, df.iloc[0]))  # Assign first row as column headers
            df = df[1:].reset_index(drop=True)  # Drop the first row and reset index
        try:
            df = df.apply(pd.to_numeric)
        except ValueError: # nothing to wory about
            pass

        if in_model_settings:
            self.model_settings[name] = df
        else:
            self.plots[plot_name][plot_stage] = df

    def _fix_multiindex_header(self, header_row, data_row):
        """Expands a malformed multi-index header by adding missing commas."""
        fixed_header = []
        col_idx = 0

        for value in header_row:
            fixed_header.append(value)
            if value:
                col_idx += 4  # Each plot has 4 sub-columns (x, y, color, pen down)
            else:
                col_idx += 1

        while len(fixed_header) < len(data_row):
            fixed_header.append("")  # Fill missing columns

        current_header = ""
        for i, header in enumerate(fixed_header):
            header = header.strip('"')
            if len(header) >= 1:
                current_header = header
            fixed_header[i] = current_header

        return fixed_header

    def print_summary(self):
        """Prints a summary of the extracted tables."""
        print("MODEL SETTINGS:")
        for name, df in self.model_settings.items():
            print(f"\n{name}:")
            print(df)

        print("\nPLOTS:")
        for plot_name, plot_data in self.plots.items():
            print(f"\nPlot: {plot_name}")
            for stage, df in plot_data.items():
                stage_name = ["Plot Metadata", "Graph Descriptions", "Graph Data", "Reorganized Graph Data"][stage]
                print(f"\n{stage_name}:")
                print(df)

    def _clean_data_frames(self):
        for plot_name in self.plots.keys():
            for stage in self.plots[plot_name].keys():
                self.plots[plot_name][stage] = (self.plots[plot_name][stage]
                                                .map(lambda x: (x.replace('"', '') if isinstance(x, str) else x)))

    def export_csv(self, output_path, file_name):
        for plot_key in self.plots.keys():
            path = os.path.join(output_path, f"{file_name}_{plot_key}.csv")
            self.plots[plot_key][3].reset_index(level=0, drop=True).to_csv(path)


def process_files(input_pattern, output_folder):
    files = glob.glob(input_pattern)
    if not files:
        logger.error("No matching files found.")
        return

    for file in files:
        logger.info(f"Processing file: {file}")
        data = ResultDataSet(file)
        #data.print_summary()
        data.export_csv(output_folder, os.path.basename(file.strip(".csv")))
        logger.info(f"Exported to: {os.path.join(output_folder, os.path.basename(file.strip(".csv")))}")


def main():
    setup_logger()

    parser = argparse.ArgumentParser(description="NetLogo CSV Reformatter")
    parser.add_argument("input", help="Input CSV file or wildcard pattern (e.g., '../measurement_*.csv')")
    parser.add_argument("output_folder", help="Output folder for reformatted CSV files")

    args = parser.parse_args()

    if not os.path.exists(args.output_folder):
        os.makedirs(args.output_folder)

    process_files(args.input, args.output_folder)


if __name__ == "__main__":
    main()
