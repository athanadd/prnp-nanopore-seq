# Nanopore sequencing of PRNP

### General info

This repo stores a how to guide and scripts that can be used for Oxford Nanopore Sequencing analysis. It was originally
designed to call Structural Variants (SVs) and Small Nucleotide Variations (SNVs) in the promoter and the PRNP gene
itself, but the options allow for configuration of your genetic locus of interest.
The project aims to provide an easy to use solution that remains configurable.

Use the pipeline provided if you start from sequencing files (fast5) to call SVs using Sniffles and SNVs using Nanopolish.
The pipeline is configured to accept multiplexed sequencing runs only, but feel free to adapt it for your own needs.

All the programs used are provided in the form of docker containers. This allows reproducibility and ease of use,
because no complex installations are necessary. Some of the containers are built by myself and some of them are
provided from the biocontainers open source project.

Most of the operations require GNU parallel and are run in parallel. However, some of them which are disk-intensive
will be run sequentially.

### Summary of steps

The pipeline follows the following sequential run of programs:
Basecalling the fast5 files (guppy) > Aligning on the reference genome (minimap2) > 
converting sam to bam, sorting and indexing (samtools) > creating indices for nanopolish (nanopolish) > 
calling SVs (sniffles) and SNVs (nanopolish) > aggregating the data and reporting in .xlsx files

### Requirements

* A reference genome file in .fasta format
* A minimap2 index created from the same reference genome file
* A functional installation of R
* Docker installed and properly configured
* GNU parallel installed and configured

### Important

This pipeline will work with the latest version of MinKNOW, that generates multi-line fast5 files.
If you use the older version that generates single-line fast5 files in different folders, then you might have
to do your own basecalling and then continue with the pipeline.

### Before you start

The most important step is to setup your own options in the global_parameters.sh file. The file is already pre-populated
with the configuration I used in my system, but should be changed to suit your needs. Please do set all the options
in this file before starting the analysis, so that everything will run smoothly.
There are some options that should be fine not to change if you follow the steps (such as the containers), and they are marked with *** at their
description.
At the end of the file I have saved some of the default options used by all the scripts. Note that if you change them, the
pipeline will be broken and the appropriate changes should take place in the scripts themselves.

You should also create a simple text file named sample_names.txt and placed in the root directory of the project.
The file is a tab-delimited document with 2 columns.
column 1 should be the name of the barcode of a specific sample (e.g. barcode01), and
column 2 should be the name of the sample that makes sense to you (e.g. my_sample_2537)
THE FILE SHOULD HAVE A BLANK NEW LINE AT THE END!!! (just press enter to create a new line and save it like that)



### Step-by-step guide

1. Clone this repo locally or create your project folder and download the files.
	You should have the R_libs folder and a scripts folder

2. Make sure you have a reference genome and a minimap2 index of the same genome and your sample_names.txt file ready

3. Open up the global_parameters.sh file and change the options to suit your needs

4. Make sure that you have permission to excecute the scripts in the scripts folder

5. Run basecall.sh
	This will create a directory named 'proccessed' that will include the basecalled fastq and fast5 files.
	Basecalling is done by Guppy.
	
6. Run barcoder.sh
	Guppy uses a different excecutable that reports the barcode found in a new directory proccessed/barcodes

7. Run demultiplex_fastq.sh
	The script will separate the different samples according to their barcode, rename them and place them
	in a new directory called fastq_files. The information for the naming of the samples is provided from the
	sample_names.txt file. 

8. Run minimap2_align.sh
	The script will run minimap2 and output .sam alignment files in a new directory aligned/sam

9. Run convert_sam_to_bam.sh
	Converts the sam files to bam. Then the bam files will have their MD string fixed. They will be
	sorted and indexed. The files will be placed in a new dir aligned/bam

10. Run sniffles_variants.sh
	Call structural varints using Sniffles. Outputs .csv files in a new directory sniffles_out

11. Run nanopolish_index.sh
	Indexes the fastq files using the fast5 files. Runs sequentially (not in parallel) because it performs
	intense disk operations.

12. Run nanopolish_variants.sh
	Calls SNVs using nanopolish. Done in parallel batches, the number of files in each batch is
	specified in the script and has to be set according to the specifications of the analysis computer.
	This procedure is very RAM-intensive. Estimate the number of parallel jobs for your system by assuming that 1 job
	needs apx. 20Gb of free RAM. The option is set in the global_parameters.sh file.

13. Run filter_results.sh
	Aggregates and filter the nanopolish and sniffles results in a new MS Excel workbook containing 3 sheets.
	The final reports will be saved in a new directory reports
