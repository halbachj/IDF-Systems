import logging

# Create a logger
logger = logging.getLogger("csv_formatter_logger")


def setup_logger():
    logger.setLevel(logging.DEBUG)  # Set the minimum level to log

    # Create a file handler
    file_handler = logging.FileHandler("csv_reformater.log")
    file_handler.setLevel(logging.DEBUG)  # Log everything to the file

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


def read_csv(path):



def main():
    setup_logger()

    logger.info("NetLogo CSV reformater")


if __name__ == "__main__":
    main()
