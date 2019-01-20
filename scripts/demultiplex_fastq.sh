#!/bin/bash

#### INFO ####
# This script should be used after generating basecalled and fastq files
# after Nanopore sequencing a pooled library with a barcoding kit.
# It will demultiplex and rename the fastq files from the workspace to a new directory
# in the project root, named fastq_files.
# Requires a text file called sample_names.txt placed in the project root directory
# that contains two tab-delimited columns. The first column is the name of the barcode
# (e.g. barcode02) and the second is the new name of the sample for renaming.
# Uses rrwick's filtering python script: https://github.com/rrwick/MinION-desktop/blob/master/filter_by_guppy_barcode.py
####

## Parameters Needed ##

# Set the path to the sample_names.txt file

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

mkdir -p $fastqdir

function demultiplex {

barcode_number=$1
sample_name=$2

docker run --rm $docker_mount --user $(id -u):$(id -g) $guppy \
python3 $DIR/scripts/filter_by_guppy_barcode.py \
$barcoded_info_dir/barcoding_summary.txt $barcode_number $basecalled_fastq_dir/*.fastq > $fastqdir/${sample_name}.fastq

}

while read -r i
do

demultiplex $i

done < ${sample_names}