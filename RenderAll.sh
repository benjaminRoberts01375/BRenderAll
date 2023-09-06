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
