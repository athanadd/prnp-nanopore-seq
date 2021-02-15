#!/bin/bash

# This script moves the bam files from the barcode folders
# to the aligned folder and renames them with the sample names
# as described by the sample_names.txt file

## Parameters Needed ##

# Set the path to the sample_names.txt file

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

function rename {

barcode_number=$1
sample_name=$2

bam_file=` ls $aligned_dir/$barcode_number | grep '\.bam$' `

cp $aligned_dir/$barcode_number/$bam_file $aligned_dir/${sample_name}.bam

}

while read -r i
do
rename $i

done < ${sample_names}