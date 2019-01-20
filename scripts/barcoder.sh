#!/bin/bash

# A script to identify barcodes on fast5 files already basecalled, using Guppy.
# Generates a barcode summary file that contains information about the id of the read and the found barcode.

## Parameters Needed ##

# Set name of docker guppy image
# Set path to raw fast5 folder
# Set basecalling worker threads
# Set docker disk mounting options

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

mkdir -p $barcoded_info_dir

docker run --rm $docker_mount --user $(id -u):$(id -g) $guppy \
guppy_barcoder --input_path $basecalled_fastq_dir --save_path $barcoded_info_dir --worker_threads $bc_wthrds
