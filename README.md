# Nanopore sequencing of PRNP gene

### General info

This repo stores a how to guide and scripts that can be used for Oxford Nanopore Sequencing analysis. It was originally
designed to call Structural Variants (SVs) and Small Nucleotide Variations (SNVs) in the promoter and the PRNP gene
itself, but the options allow for configuration of your genetic locus of interest.
The project aims to provide an easy to use solution that remains configurable.

Use the pipeline provided if you start from sequencing files (fast5) to call SVs using Medaka.
The pipeline is configured to accept multiplexed sequencing runs only, but feel free to adapt it for your own needs.

All the programs used are provided in the form of docker containers. This allows reproducibility and ease of use,
because no complex installations are necessary. Some of the containers are built by myself and some of them are
provided from the biocontainers open source project.

Most of the operations require GNU parallel and are run in parallel.

### Summary of steps

The pipeline follows the following sequential run of programs:
Basecalling the fast5 files (guppy_basecaller) > demultiplexing the files (guppy_barcoder) >
aligning on the reference genome (guppy_aligner) > indexing (samtools) >
calling SVs and SNVs (medaka) > calling large SVs (sniffles) > filtering the data and reporting in .xlsx files

### Requirements

* A reference genome file in .fasta format
* A minimap2 index created from the same reference genome file
* A functional installation of R with openxlsx installed
* Docker installed and properly configured
* GNU parallel installed and configured

### Before you start

It is important to setup your own options in the global_parameters.sh file. The file is already pre-populated,
but should be changed to suit your needs. Please do set all the options
in this file before starting the analysis, so that everything can run smoothly.
There are some options that should be fine not to change if you follow the steps (such as the containers), and they are marked with *** at their
description.

You should also create a simple text file named sample_names.txt and placed in the root directory of the project.
The file is a tab-delimited document with 2 columns.
column 1 should be the name of the barcode of a specific sample (e.g. barcode01), and
column 2 should be the name of the sample that makes sense to you (e.g. my_sample_2537)

### Step-by-step guide

1. Clone this repo locally or create your project folder and download the files.
	You should have the scripts folder and a sample_names.txt file

2. Make sure you have a reference genome and a minimap2 index of the same genome and your sample_names.txt file ready

3. Open up the global_parameters.sh file and change the options to suit your needs. Then write your file names in the sample_names.txt file.

4. Make sure that you have permission to excecute the scripts in the scripts folder

5. Run basecall.sh
	This will create a directory named 'basecalled' that will include the basecalled fastq.gz file.
	Basecalling is done by Guppy.

6. Run demultiplex.sh
	The script will separate the different samples according to their barcode and place them
	in a new directory called demultiplexed. 

7. Run guppy_align.sh
	The script will run guppy_aligner and output .bam alignment files in a new directory called aligned

8. Run rename_bams.sh
	Renames the bam files matching the barcode to the sample name using the information in the sample_names.txt.
	The renamed files are then moved out of the folders in the aligned directory.

9. Run sort_fix_index_bams.sh
	Uses samtools to sort the bam files, then fix their MD strings and finally to create indices.

10. Run run_medaka.sh
	Runs medaka_variants for the files in parallel. Creates a medaka_out directory that will contain the output
	files. Requires a large amount of RAM memory.

11. Run run_sniffles.sh
	Runs sniffles for the files in parallel. Creates a sniffles_out directory that will contain the output
	files.

12. Run filter_results.sh
	Filters the vcf files exported by medaka and sniffles and saves the output in a new MS Excel workbook.
	The final reports will be saved in a new directory called reports
