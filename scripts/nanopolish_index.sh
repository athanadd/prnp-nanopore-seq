#!/bin/bash

# Run this script before calling nanopolish variants. It will create index files placed in the fastq directory.
# Needs the basecalled, passed fast5 files to create the indices.

## Parameters Needed ##

# Set name of docker nanopolish image
# Set the path to the sample_names.txt file

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

mkdir -p $DIR/nanopolish_out

function nanopolish_variants {

# Get the arguments
barcode=$1
filename=$2

docker run --rm $docker_mount --user $(id -u):$(id -g) $nanopolish_image /bin/bash -c "\
nanopolish index -d $barcode_folders -s $seq_summary $fastqdir/${filename}.fastq"
}

# Export the function
export -f nanopolish_variants

# Run function
while IFS=$'\t' read -r i
do

nanopolish_variants $i

done < $sample_names








