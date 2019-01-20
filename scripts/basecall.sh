#!/bin/bash

# A script to run basecalling on fast5 files generated from Oxford Nanopore MinION, using Guppy.
# Generates filtered fastq and fast5 files in an output folder named "proccessed".

## Parameters Needed ##

# Set name of docker guppy image
# Set path to raw fast5 folder
# Set q-score quality cutoff when basecalling with Guppy
# Set basecalling worker threads
# Set docker disk mounting options

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

mkdir -p $DIR/proccessed/2

docker run --rm $docker_mount --user $(id -u):$(id -g) $guppy \
guppy_basecaller --qscore_filtering --min_qscore $q_score --flowcell FLO-MIN106 --kit SQK-RPB004 --input $raw_fast5_folder --fast5_out --save_path $DIR/proccessed -r -q 0 --worker_threads $bc_wthrds
