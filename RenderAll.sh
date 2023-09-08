#!/bin/bash

# Get a directory to folder of Blend files
USAGE="Usage: $0 [Path to directory]"
output_dir=""
blender_options=""

while getopts ":o:b:" opt; do
	case $opt in
		o)
			output_dir=$OPTARG
			;;
		b)
			blender_options=$OPTARG
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done

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
blender_executable="/home/benroberts/Desktop/blender-4.0.0-alpha+main.d45f47a809dd-linux.x86_64-release/blender" # Useful to specify a particular blender installation

# Declare how many were found
file_count=$(find $project_folder -maxdepth 1 -type f -name "*.blend" | wc -l)
if [[ $file_count == 1 ]]; then
	echo "Found $file_count blend file"
else
	echo "Found $file_count blend files"
fi

echo "Current Dir: $(pwd)"
echo "Project folder: $project_folder"
project_folder=$(realpath "$project_folder")
echo "Project folder: $project_folder"

finished_rendering=false
#while [[ $finished_rendering != true ]]; do
	echo "Starting loop"
	for project_file_path in "$project_folder"/*.blend; do
		project_file=$(basename -- "$project_file_path") # Name of project file without path leading to it (has extension still)
		echo "Now rendering $project_file"
		project_file_no_ext=${project_file%.blend} # Name of project file without extension
		output_folder="$project_folder/Blender Renders/$project_file_no_ext"
		find "$output_folder" -type f -size 0 -exec rm {} ';'
		mkdir "$output_folder" -p # Folder to render into
		$blender_executable -b "$project_file_path" -o "$output_folder/$project_namme_no_ext" -a
	done
#done
