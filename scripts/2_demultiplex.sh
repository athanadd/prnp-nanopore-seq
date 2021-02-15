#!/bin/bash

# Separates the basecalled reads into different folders based on their barcodes using guppy_barcoder.

## Parameters Needed ##

# Set name of docker guppy image
# Set path to basecalled fastq files
# Set basecalling worker threads
# Set docker disk mounting options

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

mkdir -p $demultiplexed_dir

docker run --rm $docker_mount --user $(id -u):$(id -g) $guppy \
guppy_barcoder --input_path $basecalled_fastq_dir --save_path $demultiplexed_dir --barcode_kits $bc_kit --worker_threads $bc_wthrds -q 0 --compress_fastq
