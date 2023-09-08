#!/bin/bash

output_dir=""
blender_options="empty"
project_folder=""

while (($#)); do
	case $1 in
		-o)
			if [[ -d "$2" ]]; then
				output_dir="$1"
				shift
				shift
			else
				while true; do
					read -p "Are you sure you want to create the directory \""$2"\"? [Y/n]" response
					case $response in
						[Yy]*|"" )
							output_dir="$2"
							mkdir "$2" -p
							shift
							shift
							break
							;;
						[Nn]* )
							exit 0
							;;
						* )
							echo "Huh?"
							;;
					esac
				done
			fi
			;;
		* )
			if [[ -d $1 ]]; then
				project_folder=$(realpath "$1")
			else
				echo "Invalid argument $1"
				exit 1
			fi
			shift
			;;
	esac
done

blender_executable="/home/benroberts/Desktop/blender-4.0.0-alpha+main.d45f47a809dd-linux.x86_64-release/blender" # Useful to specify a particular blender installation

# Declare how many were found
file_count=$(find $project_folder -maxdepth 1 -type f -name "*.blend" | wc -l)
if [[ $file_count == 1 ]]; then
	echo "Found $file_count blend file"
else
	echo "Found $file_count blend files"
fi

finished_rendering=false
#while [[ $finished_rendering != true ]]; do
	echo "Starting loop"
	for project_file_path in "$project_folder"/*.blend; do
		project_file=$(basename -- "$project_file_path") # Name of project file without path leading to it (has extension still)
		echo "Now rendering $project_file"
		project_file_no_ext=${project_file%.blend} # Name of project file without extension
		output_folder="$project_folder/Blender Renders/$project_file_no_ext"
		find "$output_folder" -type f -size 0 -exec rm {} ';'
		"$blender_executable" -b "$project_file_path" -o "$output_folder/$project_namme_no_ext" -a
	done
#done
