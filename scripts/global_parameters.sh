#!/bin/bash

#### Main ####

# Set the directory of the project
export DIR=/mnt/disk3_36TB/Thanos_sequencing/promoter_batch_1

# *** Set the path to sample_names.txt file (read the instructions first!)
export sample_names=$DIR/sample_names.txt

#### Docker ####

# *** Set name of docker samtools image
export samtools_image=biocontainers/samtools:v1.7.0_cv3

# *** Set name of docker ONT guppy image
export guppy=athanadd/ont-guppy:2.1.3

# *** Set name of docker minimap2 image
export minimap2_image=athanadd/minimap2:2.13

# *** Set name of docker nanopolish image
export nanopolish_image=athanadd/nanopolish:0.10.2

# *** Set name of docker sniffles image
export sniffles_image=quay.io/biocontainers/sniffles:1.0.10--hd4ff3c4_0

# Set docker disk mounting options (check docker manual if unsure)
# Mount disk should contain all the required files.
export docker_mount="-v /mnt:/mnt"

#### Other ####

# Set the genomic range that you want reported (chromosome, starting position, ending position)
export gen_range_chr=chr20
export gen_range_start=4685200
export gen_range_end=4701800

# *** Set q-score quality cutoff when basecalling with Guppy (default: 7.0)
export q_score=7.0

# *** Set path to R library files
export libs_path=$DIR/R_lib

# Set genome fasta file (to fix MD headers of reads)
export genome=/mnt/disk3_36TB/Thanos_sequencing/required_files/etc/genomes/hg38/hg38.fa

# Set path to reference genome index file (minimap2)
export index=/mnt/disk3_36TB/Thanos_sequencing/required_files/etc/minimap2/hg38.mmi

# Set path to raw fast5 folder
export raw_fast5_folder=/mnt/win/Thanos/PRNP_sequencing/promoter_batch_1/20190109_1455_MN28445_FAK45966_0d3c4853/fast5

# *** Set minimum length of structural variants to be reported by sniffles
export sniffles_min_var_length=20

# Set minimum read length accepted by sniffles (default: 2000)
export min_read_length=2000

#### Performance ####

# Set number of threads to be used for the proccess of each sample in various multithreaded operations
export thrds=15

# *** Set number of parallel jobs for nanopolish variants (each job requires a lot of RAM. Up to 20-30Gb for a 1Gb fastq file)
export nanopolish_variants_jobs=2

# Set basecalling worker threads
export bc_wthrds=100


############
# DEFAULTS #
############
# These defaults will be used by the scripts.
# Please do not alter these values if you don't know what you're doing.

# Set the directory that guppy places the basecalled, filtered fastq files
export basecalled_fastq_dir=$DIR/proccessed/pass

# Set the path to sequencing_summary.txt generated when basecalling
export seq_summary=$DIR/proccessed/sequencing_summary.txt

# Set the directory that will contain the barcoded information
export barcoded_info_dir=$DIR/proccessed/barcodes

# Set the directory that contains the basecalled fast5 files
export barcode_folders=$DIR/proccessed/workspace

#Set path to fastq files
export fastqdir=$DIR/fastq_files

# Set path to aligned sam folder
export samdir=$DIR/aligned/sam

# Set path to aligned bam folder
export bamdir=$DIR/aligned/bam

# Set path to sniffles variants directory
export sniffles_variants_dir=$DIR/sniffles_out

# Set path to nanopolish variants directory
export nanopolish_variants_dir=$DIR/nanopolish_out



