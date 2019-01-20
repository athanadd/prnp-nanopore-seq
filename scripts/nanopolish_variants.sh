#!/bin/bash

# This script calls nanopolish variants to find SNPs only (can be changed).
# Needs the fastq files to be indexed first by calling nanopolish_index.sh
# Creates a new directory called nanopolish_out where it places the results.

## Parameters Needed ##

# Set name of docker nanopolish image
# Set the path to the sample_names.txt file
# Set genome file 
# Set number of parallel jobs for nanopolish variants (each job requires a lot of RAM. Up to 40-50Gb for a 2Gb fastq file)
# Set number of threads to be used for the proccess of each sample in various multithreaded operations
# Set the genomic range that you want reported (chromosome, starting position, ending position)

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

mkdir -p $DIR/nanopolish_out

function nanopolish_variants {

# Get the arguments
sample_info=$1

filename="$(echo $sample_info | cut -d ' ' -f2)"
barcode="$(echo $sample_info | cut -d ' ' -f1)"

docker run --rm $docker_mount --user $(id -u):$(id -g) $nanopolish_image /bin/bash -c "\
nanopolish variants -r $fastqdir/${filename}.fastq -b $bamdir/${filename}_sorted_mdfix.bam -w '${gen_range_chr}:${gen_range_start}-${gen_range_end}' -g $genome -p 2 \
-o $DIR/nanopolish_out/${filename}_nanopolish_variants.vcf -t $thrds --snps"
}

# Export the function
export -f nanopolish_variants

# Run function in parallel
parallel --link -j $nanopolish_variants_jobs -a $sample_names nanopolish_variants







