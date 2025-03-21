import argparse
import glob
import io
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
    console_handler.setLevel(logging.INFO)  # Only log INFO and above to stdout

    # Define a formatter
    formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

    # Apply the formatter to both handlers
    file_handler.setFormatter(formatter)
    console_handler.setFormatter(formatter)

    # Add handlers to the logger
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)


class ResultDataSet:
    data: pd.DataFrame = None
    header: list = None

    def __init__(self, path: str):
        self.read_csv(path)

    def clean_up_raw_csv(self, raw_csv: [str]):
        column_headers = raw_csv[0].strip()
        column_headers += ("," * 3)
        column_headers = column_headers.split(",")
        new_headers = []
        current_header = ""
        for header in column_headers:
            if len(header) > 0: # header needs to be saved
                logger.debug(f"reading header: {header}")
                current_header = header
            new_headers.append(current_header)
        final_headers = ",".join(new_headers)
        final_headers = final_headers.strip(",\n") + "\n"
        logger.debug(final_headers)
        raw_csv[0] = final_headers
        return raw_csv


    def parse_raw_csv(self, raw_data: io.StringIO):
        self.data = pd.read_csv(raw_data, header=[0, 1])
        self.data.columns = self.data.columns.map(lambda x: (x[0].strip('"'), x[1].strip('"')))
        self.data = self.data.apply(pd.to_numeric)

    def read_csv(self, path):
        with open(path, "r") as csv_file:
            raw_data = csv_file.readlines() # read the file header first
            self.header = raw_data[:17]
            clean_csv = self.clean_up_raw_csv(raw_data[17:])
            clean_csv_buffer = io.StringIO("".join(clean_csv))
            self.parse_raw_csv(clean_csv_buffer)

    def reorganize_data(self):
        self.data = self.data.stack(level=0, future_stack=True)
        self.data = self.data.iloc[self.data.index.get_level_values(1).argsort(kind='stable')]
        self.data.index.names = ["index", "course"]
        self.data.drop(columns=["color", "pen down?"], inplace=True)
        self.data.rename(columns={"x": "ticks", "y": "happy"}, inplace=True)
        logger.debug(self.data.index)

    def export_csv(self, path):
        output = "".join(self.header)
        output += self.data.reset_index(level=0, drop=True).to_csv()
        with open(path, "w") as csv_file:
            csv_file.write(output)


def process_files(input_pattern, output_folder):
    files = glob.glob(input_pattern)
    if not files:
        logger.error("No matching files found.")
        return

    for file in files:
        logger.info(f"Processing file: {file}")
        data = ResultDataSet(file)
        data.reorganize_data()
        output_file = os.path.join(output_folder, os.path.basename(file))
        data.export_csv(output_file)
        logger.info(f"Exported to: {output_file}")

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
