import os
import pandas as pd
import argparse

def read_bed_file(file_path):
    return pd.read_csv(file_path, sep='\t', header=None)

def fill_missing_intervals(reference_df, compare_df):
    compare_coords = set(tuple(x) for x in compare_df.iloc[:, :3].values)
    missing_intervals = []
    for index, row in reference_df.iterrows():
        interval = tuple(row[:3])
        if interval not in compare_coords:
            missing_intervals.append(interval + ('NA',) * 40)
    return pd.DataFrame(missing_intervals)

def process_files(reference_prefix, suffix, directory):
    # Get reference file
    reference_file = None
    for file in os.listdir(directory):
        if file.startswith(reference_prefix) and file.endswith(suffix):
            reference_file = os.path.join(directory, file)
            break

    if not reference_file:
        print(f"No reference file with prefix '{reference_prefix}' and suffix '{suffix}' found.")
        return

    reference_df = read_bed_file(reference_file)

    # Process each file with the same suffix
    for file in os.listdir(directory):
        if file.endswith(suffix) and not file.startswith(reference_prefix):
            file_path = os.path.join(directory, file)
            compare_df = read_bed_file(file_path)
            missing_df = fill_missing_intervals(reference_df, compare_df)

            if not missing_df.empty:
                compare_df = pd.concat([compare_df, missing_df])
                compare_df.sort_values(by=[0, 1, 2], inplace=True)
                compare_df.to_csv(file_path, sep='\t', header=False, index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process BED files to fill missing intervals.')
    parser.add_argument('reference_prefix', type=str, help='Prefix of the reference file')
    parser.add_argument('suffix', type=str, help='Common suffix of the files to process')
    parser.add_argument('directory', type=str, help='Directory containing the files')

    args = parser.parse_args()
    process_files(args.reference_prefix, args.suffix, args.directory)
