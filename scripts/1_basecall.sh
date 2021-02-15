#!/bin/bash

# A script to run basecalling on fast5 files generated from Oxford Nanopore MinION, using Guppy.
# Generates a fastq.gz file in an output folder named "basecalled".

## Parameters Needed ##

# Set name of docker guppy image
# Set flowcell and sequencing kits
# Set path to raw fast5 folder
# Set docker disk mounting options

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

mkdir -p $basecalled_fastq_dir

docker run --rm $docker_mount --user $(id -u):$(id -g) $guppy \
guppy_basecaller --flowcell $flowcell --kit $seq_kit --input_path $fast5_folder --save_path $basecalled_fastq_dir --recursive --compress_fastq --device cuda:all -q 0
