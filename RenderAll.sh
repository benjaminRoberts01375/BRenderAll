#!/bin/bash

output_dir=""
blender_options=""
project_folder=""
check_frames=true
frames_subfolder_name="Rendered Frames"

while (($#)); do
	case $1 in
		-c)
			check_frames=false
			shift
			;;

		-a)
			blender_options="-a $blender_options"
			shift
			;;
		-e) # Specify end frame
			blender_options="-e $2 $blender_options"
			shift
			shift
			;;
		-f)
			if [[ $2 =~ ^-?[0-9]+$ ]]; then
				blender_options="-f $2"
				shift
				shift
			else
				echo "-f requires a number (positive or negative)"
				exit 1
			fi
			;;
		-o)
			if [[ $2 == "" ]]; then
				echo "You must provide an output path with the -o flag."
				exit 1
			fi
			absolute_dir=$(realpath "$2")
			if [[ -d "$absolute_dir" ]]; then
				output_dir="$absolute_dir"
				shift
				shift
			else
				while true; do
					read -p "Are you sure you want to create the directory \""$absolute_dir"\"? [Y/n] " response
					case $response in
						[Yy]*|"" )
							output_dir="$absolute_dir"
							mkdir "$absolute_dir" -p
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
		-s) # Specify start frame
			blender_options="-s $2 $blender_options"
			shift
			shift
			;;
		* )
			if [[ -d $1 ]]; then
				project_folder=$(realpath "$1")
			else
				echo "Invalid argument: $1"
				exit 1
			fi
			shift
			;;
	esac
done

# Check if an input was provided
if [ -z $project_folder ]; then
	echo "Usage $0 <Input directory> [flags]"
	exit 1
fi

blender_executable="/home/benroberts/Desktop/blender-4.0.0-alpha+main.d45f47a809dd-linux.x86_64-release/blender" # Useful to specify a particular blender installation

# Declare how many were found
file_count=$(find $project_folder -maxdepth 1 -type f -name "*.blend" | wc -l)

if [[ $file_count == 0 ]]; then
	echo "No blend files were found in $project_folder."
	exit 1
elif [[ $file_count == 1 ]]; then
	echo "Found $file_count blend file"
else
	echo "Found $file_count blend files"
fi

# Check if a specific output directory was passed
if [[ -z $output_dir ]]; then
	output_dir="$project_folder"/"$frames_subfolder_name"
	mkdir "$output_dir" -p
fi

finished_rendering=false
while [[ $finished_rendering != true ]]; do
	# Render all available
	for project_file_path in "$project_folder"/*.blend; do
		project_file=$(basename -- "$project_file_path") # Name of project file without path leading to it (has extension still)
		project_file_no_ext=${project_file%.blend} # Name of project file without extension
		output_folder="$output_dir/$project_file_no_ext"
		if [[ ! -d $output_folder ]]; then
			mkdir "$output_folder"
		fi
		rendered_frames=$(find "$output_folder" -type f -name "*.png" | wc -l)
		# Check to ensure all frames have been rendered
		if [ $check_frames = true ] && [ $rendered_frames -gt 0 ] ; then
			# Output the first and last frame to render
			frame_output=$("$blender_executable" -b "$project_file_path" --python-expr "import bpy; print(bpy.context.scene.frame_end); print(bpy.context.scene.frame_start)" )
			start_frame=$(echo "$frame_output" | awk 'NR==2')
			end_frame=$(echo "$frame_output" | awk 'NR==1')
			# Override if frame range has been specified
			if [[ $blender_options == *-s* ]]; then
				echo "Override start frames"
				start_frame=$(echo "$frame_output" | grep -oP '(?<=-s\s)\d+') # Grep pearl expression to look for a "-s NUM"
			fi
			if [[ $blender_options == *-e* ]]; then
				echo "Override end frames"
				end_frame=$(echo "$frame_output" | grep -oP '(?<=-e\s)\d+') # Grep pearl expression to look for a "-e NUM"
			fi
			if (( rendered_frames == end_frame - start_frame + 1)); then
				finished_rendering=true
				echo "Done rendering $project_file_no_ext"
				continue
			else
				finished_rendering=false
			fi
		fi

		echo "Now rendering $project_file"
		find "$output_folder" -type f -size 0 -exec rm {} ';' > /dev/null
		"$blender_executable" -b "$project_file_path" -o "$output_folder/$project_name_no_ext" $blender_options
	done
	finished_rendering=true # Temp until "double checking" is implemented
done
