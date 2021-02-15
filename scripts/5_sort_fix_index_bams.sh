#!/bin/bash


## Parameters Needed ##

# Set name of docker samtools image
# Set number of threads to be used for the proccess of each sample in various multithreaded operations

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

files=` ls $aligned_dir | grep '\.bam$' `

function sort_fix_index_bams {

# Get the arguments
file=$1

filename=` echo $file | sed -e 's|.bam||g' `

docker run --rm $docker_mount --user $(id -u):$(id -g) $samtools_image /bin/bash -c "\
samtools sort -@ $thrds -o $aligned_dir/${filename}_sorted.bam $aligned_dir/$file &&
samtools index $aligned_dir/${filename}_sorted.bam &&
samtools calmd $aligned_dir/${filename}_sorted.bam $genome -b > $aligned_dir/${filename}_sorted_mdfix.bam &&
samtools index $aligned_dir/${filename}_sorted_mdfix.bam &&
rm $aligned_dir/${filename}.bam &&
rm $aligned_dir/${filename}_sorted.bam &&
rm $aligned_dir/${filename}_sorted.bam.bai"
}

# Export the function
export -f sort_fix_index_bams

# Run function in parallel
parallel --link sort_fix_index_bams ::: $files





