#!/bin/bash

####

# A script to run variant caller medaka.
# Used to generate a vcf file with variants and additional haplotype information.

## Parameters Needed ##

# Set name of docker medaka image
# Set path to reference genome fasta file
# Set number of threads to be used for the proccess of each sample in various multithreaded operations

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

files=` ls $aligned_dir | grep '\.bam$' `

mkdir -p $medaka_dir

function run_medaka {

# Get the arguments
bam_file=$1

# Get the filename
filename=` echo $bam_file | sed -e 's|.bam||g' `

# It is not recommended to specify a value of --threads greater than 8
# for medaka since the compute scaling efficiency is poor beyond this.
# If the threads have been set to a higher number, set them to 8.
if [[ $thrds -gt 8 ]]
then
    local_thrds=8
else
    local_thrds=$thrds
fi

docker run --rm $docker_mount --user $(id -u):$(id -g) $medaka_image \
/bin/bash -c "cd /medaka && . medaka/bin/activate && medaka_variant -i $aligned_dir/$bam_file -f $genome -o $medaka_dir/$filename -t $local_thrds"
}

# Export the function
export -f run_medaka

# Run function in parallel
parallel --link -j $medaka_jobs run_medaka ::: $files