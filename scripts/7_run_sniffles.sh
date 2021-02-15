#!/bin/bash

# This script calls structural variants using sniffles. It will report variants longer than 20bp (can be changed).
# The output files will be placed in a new directory called sniffles_out.

## Parameters Needed ##

# Set name of docker sniffles image
# Set minimum length of structural variants to be reported by sniffles
# Set number of threads to be used for the proccess of each sample in various multithreaded operations
# Set minimum read length accepted by sniffles

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

mkdir -p $sniffles_dir
files=` ls $aligned_dir | grep '\_sorted_mdfix.bam$' `

function sniffles_variants {

# Get the arguments
file=$1

filename=` echo $file | sed -e 's|_sorted_mdfix.bam||g' `

docker run --rm $docker_mount --user $(id -u):$(id -g) $sniffles_image \
sniffles --genotype --report_seq --report_read_strands -s 100 -r $min_read_length --min_length $sniffles_min_var_length -t $thrds -m $aligned_dir/$file -v $sniffles_dir/${filename}_sniffles.vcf
}

# Export the function
export -f sniffles_variants

# Run function in parallel
parallel --link sniffles_variants ::: $files