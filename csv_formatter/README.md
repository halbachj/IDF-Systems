# NetLogo CSV Reformatter

This script processes NetLogo CSV files, reorganizes the data, and exports the modified files to a specified output folder.

## Features
- Accepts individual file paths or wildcard patterns (e.g., `measurement_*.csv`).
- Processes multiple files in a batch.
- Saves reformatted files to a specified output folder.
- Logs processing steps for visibility.

## Requirements
- Python 3.x
- Pandas >= 2.10

## Installation
To install the required dependencies, make sure you have Python installed, then run the following command:

```sh
pip install -r requirements.txt
```

If you are using a virtual environment, create and activate it before installing dependencies:

```sh
python -m venv venv  # Create virtual environment
source venv/bin/activate  # On macOS/Linux
venv\Scripts\activate  # On Windows
pip install -r requirements.txt  # Install dependencies
```

## Usage
Run the script from the command line:

```sh
python script.py "measurement_*.csv" "output_folder/"
```

### Arguments:
- `input` – Path to a CSV file or wildcard pattern for multiple files.
- `output_folder` – Directory where reformatted files will be saved.

The script will create the output folder if it does not exist.

## Logging
Processing steps and errors are logged to the console for better tracking.

## License
MIT License (if applicable).

