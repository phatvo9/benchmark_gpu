import os
import zipfile
import shutil
import gdown
import argparse
import tempfile

DEST_DIR = 'external/model_benchmark'
ZIP_PATH = 'model_repo.zip'

def download_zip_from_url(url, output_path):
    print(f"Downloading from: {url}")
    gdown.download(url, output_path, quiet=False, fuzzy=True)

def extract_and_flatten(zip_path, dest_dir):
    # Use temporary directory for initial extraction
    with tempfile.TemporaryDirectory() as tmp_extract_dir:
        print(f"Extracting zip to temp dir: {tmp_extract_dir}")
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(tmp_extract_dir)

        # Find the top-level extracted folder
        extracted_items = os.listdir(tmp_extract_dir)
        if len(extracted_items) != 1:
            raise RuntimeError("Expected one top-level folder in the zip file.")

        top_dir = os.path.join(tmp_extract_dir, extracted_items[0])
        if not os.path.isdir(top_dir):
            raise RuntimeError("Top-level item is not a directory.")

        # Clean destination and move contents
        print(f"Moving contents from {top_dir} to {dest_dir}")
        if os.path.exists(dest_dir):
            shutil.rmtree(dest_dir)
        shutil.copytree(top_dir, dest_dir)

    print("Extraction and flattening complete.")

def main():
    parser = argparse.ArgumentParser(description="Download and extract zip from Google Drive URL.")
    parser.add_argument('gdrive_url', help="Google Drive shareable URL of the zip file.")
    args = parser.parse_args()

    download_zip_from_url(args.gdrive_url, ZIP_PATH)
    extract_and_flatten(ZIP_PATH, DEST_DIR)
    os.remove(ZIP_PATH)

if __name__ == '__main__':
    main()
