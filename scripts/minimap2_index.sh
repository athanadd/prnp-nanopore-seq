#!/bin/bash

# A script to create a reference index file (mmi) used by minimap2.
# Requires a reference genome in fasta format.
# Always use the same fasta with the same mmi in a pipeline.

## Parameters Needed ##

# Set genome fasta file
# Set number of threads to be used for the proccess of each sample in various multithreaded operations
# Set path to reference genome index file to be generated

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh


docker run --rm $docker_mount --user $(id -u):$(id -g) $minimap2_image \
minimap2 -t $thrds -d $minimap2_index $genome