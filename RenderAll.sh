#!/bin/bash

# Get a directory to folder of Blend files
if [ $# -ne 1 ]; then
	echo "Usage: $0" [Path]
	exit 1
fi
