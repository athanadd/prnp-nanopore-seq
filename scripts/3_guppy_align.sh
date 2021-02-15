#!/bin/bash

####

# A script to run short and long read aligner minimap2, included in the guppy release.
# Used to align the demultiplexed fastq files to a reference genome.
# Exports a bam file.

## Parameters Needed ##

# Set name of docker guppy image
# Set path to reference genome index file (minimap2)
# Set the path to the sample_names.txt file
# Set number of threads to be used for the proccess of each sample in various multithreaded operations

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

function align_files {

# Get the arguments
barcode_number=$1

# Output directory
out_dir=$aligned_dir/$barcode_number

mkdir -p $out_dir

docker run --rm $docker_mount --user $(id -u):$(id -g) $guppy \
guppy_aligner --input_path $demultiplexed_dir/$barcode_number --save_path $out_dir --align_ref $minimap2_index --bam --worker_threads $thrds
}

# Export the function
export -f align_files

# Run function in parallel
cat $sample_names | awk '{print $1}' | parallel --link align_files