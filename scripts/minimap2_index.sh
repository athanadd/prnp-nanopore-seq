#!/bin/bash

# A script to create a reference index file (mmi) used by minimap2.
# Requires a reference genome in fasta format.
# Always use the same fasta with the same mmi in a pipeline.

## Parameters Needed ##

# Set genome fasta file
# Set number of threads to be used for the proccess of each sample in various multithreaded operations
# Set the output file to generate (specify it here, not in global_parameters)
index_output=/mnt/disk3_36TB/Thanos_sequencing/required_files/etc/minimap2/hg38.mmi

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh


docker run --rm $docker_mount --user $(id -u):$(id -g) $minimap2_image \
minimap2 -t $thrds -d $output $genome