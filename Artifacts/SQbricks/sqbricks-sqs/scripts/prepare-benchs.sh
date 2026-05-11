#!/bin/bash

#  This file is part of SQbricks.
#
#  Copyright (C) 2022-2025
#  CEA (Commissariat à l'énergie atomique et aux énergies alternatives)
#  Université Paris-Saclay
#
#  you can redistribute it and/or modify it under the terms of the GNU
#  Lesser General Public License as published by the Free Software
#  Foundation, version 2.1.
#
#  It is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  See the GNU Lesser General Public License version 2.1
#  for more details (enclosed in the file licenses/LGPLv2.1).

# Check if an argument is provided
if [ $# -eq 0 ]; then
	echo "Usage: $0 <directory>"
	exit 1
fi

# Check if the directory exists
if [ ! -d "$1" ]; then
	echo "Error: The directory $1 does not exist."
	exit 1
fi

# Create the processed directory if it doesn't exist
processed_dir="$1/processed"
mkdir -p "$processed_dir"

# Loop over each CSV file in the directory
for file in "$1"/*.csv; do
	# Check if the file exists to handle cases where there are no CSV files
	if [ ! -f "$file" ]; then
		continue
	fi

	# Define the output file name
	output_file="$processed_dir/$(basename "${file%.*}")_processed.csv"

	# Store the header line
	header_line=$(head -n 1 "$file")

	# Use awk to process the CSV file with semicolon as the delimiter
	awk -F';' -v header="$header_line" '
    BEGIN {
        OFS = ";"
        colonneTime = -1
        colonneVersion = -1
    }

    # Find the columns "Time" and "Version" in the first row
    NR == 1 {
        for (j = 1; j <= NF; j++) {
            if ($j == "Time") {
                colonneTime = j
            }
            if ($j == "Version") {
                colonneVersion = j
            }
        }
        if (colonneTime == -1) {
            print "Error: The column \047Time\047 was not found." > "/dev/stderr"
            exit 1
        }
        if (colonneVersion == -1) {
            print "Error: The column \047Version\047 was not found." > "/dev/stderr"
            exit 1
        }
    }

    # Print the header line only once
    NR == 1 { print; next }

    # Skip lines that are empty, contain only semicolons and possibly "TO", contain "ErrConv", or are duplicate headers
    {
        if (NF == 0 || ($0 ~ /^;*TO?;*$/) || $0 ~ /ErrConv/ || $0 == header) {
            next
        }
    }

    # Replace specific error strings in the "Time" column
    {
        if ($colonneTime == "Err1" || $colonneTime == "Err2" || $colonneTime == "Err127" || $colonneTime == "Err134" || $colonneTime == "Err139" || $colonneTime == "Err143" || $colonneTime == "Err251" || $colonneTime == "Err") {
            $colonneTime = "Fail"
        } else if ($colonneTime == "Err124" || $colonneTime == "Err137" || $colonneTime == "") {
            $colonneTime = "TO"
        } else if ($colonneTime == "SubCircuitInconclusive") {
					$colonneTime = "NC"
				} else if ($colonneTime == "Entanglement1") {
					$colonneTime = "NS"
				} 
    }

    # Print the processed line
    { print }
    ' "$file" >"$output_file"

	echo "Processed: $file -> $output_file"
done

echo "All files processed. Results are saved in $processed_dir"
