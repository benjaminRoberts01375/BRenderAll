#!/bin/bash

# Get a directory to folder of Blend files
USAGE="Usage: $0 [Path to directory]"

if [ $# -ne 1 ]; then
	echo "Incorrect argument count"
	echo $USAGE
	exit 1
elif [[ ! -d $1 ]]; then
	echo "Provided path is not a directory"
	echo $USAGE
	exit 1
fi

project_folder="$1" # A funner name

# Declare how many were found
file_count=$(find $project_folder -maxdepth 1 -type f -name "*.blend" | wc -l)
if [[ $file_count == 1 ]]; then
	echo "Found $file_count blend file"
else
	echo "Found $file_count blend files"
fi
