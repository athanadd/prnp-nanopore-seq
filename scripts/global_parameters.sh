#!/bin/bash

#### Main ####

# Set the directory of the project
export DIR=project_directory

# *** Set the path to sample_names.txt file (read the instructions first!)
export sample_names=$DIR/sample_names.txt

#### Docker ####

# *** Set name of docker samtools image
export samtools_image=biocontainers/samtools:v1.7.0_cv3

# *** Set name of docker ONT guppy image
export guppy=athanadd/ont-guppy:4.2.2

# *** Set name of docker minimap2 image
export minimap2_image=athanadd/minimap2:2.17

# *** Set name of docker medaka image
export medaka_image=athanadd/medaka:1.2.2

# *** Set name of docker sniffles image
export sniffles_image=biocontainers/sniffles:v1.0.11ds-1-deb_cv1

# Set docker disk mounting options (check docker manual if unsure)
# Mounted disk should contain all the required files.
export docker_mount="-v /mnt:/mnt"

#### Sequencing ####

# Set the flowcell, sequencing and barcoding kit used
export flowcell=FLO-MIN106

export seq_kit=SQK-RPB004

export bc_kit=SQK-RPB004

#### Other ####

# Set the genomic range that you want reported (chromosome, starting position, ending position)
export gen_range_chr=chr20
export gen_range_start=4686350
export gen_range_end=4701590

# *** Set path to R library files
export libs_path=$DIR/R_lib

# Set genome fasta file
export genome=hg38_chr20/chr20.fa

# Set path to reference genome index file (minimap2)
export minimap2_index=minimap2/hg38_chr20.mmi

# Set path to raw fast5 folder
export fast5_folder=fast5_folder

# *** Set minimum length of structural variants to be reported by sniffles
export sniffles_min_var_length=20

# Set minimum read length accepted by sniffles (default: 2000)
export min_read_length=2000

#### Performance ####

# Set number of threads to be used for the proccess of each sample in various multithreaded operations
export thrds=15

# Set barcode demultiplexing worker threads
export bc_wthrds=100

# Set number of medaka jobs to be done in parallel
export medaka_jobs=4

############
# DEFAULTS #
############
# These defaults will be used by the scripts.
# Please do not alter these values.

# Set the directory that guppy places the basecalled fastq files
export basecalled_fastq_dir=$DIR/basecalled

# Set the directory that will contain the demultiplexed fastq files
export demultiplexed_dir=$DIR/basecalled/demultiplexed

# Set path to aligned bam folder
export aligned_dir=$DIR/aligned

# Set path to medaka output directory
export medaka_dir=$DIR/medaka_out

# Set path to sniffles output directory
export sniffles_dir=$DIR/sniffles_out

# Set path to reports directory
export reports_dir=$DIR/reports