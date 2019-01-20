#!/bin/bash


## Parameters Needed ##

# Set name of docker samtools image
# Set genome fasta file (to fix MD headers of reads)
# Set number of threads to be used for the proccess of each sample in various multithreaded operations

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

mkdir -p $DIR/aligned/bam
files=` ls $samdir | grep '\.sam$' `

function convert_sam_to_bam {

# Get the arguments
file=$1

# Get the filename
filename=` echo $file | sed -e 's|.sam||g' `

docker run --rm $docker_mount --user $(id -u):$(id -g) $samtools_image /bin/bash -c "\
samtools view -@ $thrds -S -b $samdir/$file > $bamdir/${filename}.bam &&
samtools sort -@ $thrds -o $bamdir/${filename}_sorted.bam $bamdir/${filename}.bam &&
samtools index $bamdir/${filename}_sorted.bam &&
samtools calmd $bamdir/${filename}_sorted.bam $genome -b > $bamdir/${filename}_sorted_mdfix.bam &&
samtools index $bamdir/${filename}_sorted_mdfix.bam &&
rm $bamdir/${filename}.bam &&
rm $bamdir/${filename}_sorted.bam &&
rm $bamdir/${filename}_sorted.bam.bai"
}

# Export the function
export -f convert_sam_to_bam

# Run function in parallel
parallel --link convert_sam_to_bam ::: $files





