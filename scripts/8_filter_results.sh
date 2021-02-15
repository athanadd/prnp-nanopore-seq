#!/bin/bash

## Parameters Needed ##

# Set path to R library files
# Set the path to the sample_names.txt file
# Set the genomic range that you want reported (chromosome, starting position, ending position)

####

# Get global parameters from file
scripts_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_folder/global_parameters.sh

function filter {

R --vanilla --quiet << 'RSCRIPT'
medaka.file <- Sys.getenv("medaka_file")
sniffles.file <- Sys.getenv("sniffles_file")
outfile <- Sys.getenv("outfile")
filename <- Sys.getenv("filename")
chromosome <- Sys.getenv("gen_range_chr")
startPos <- as.integer(Sys.getenv("gen_range_start"))
endPos <- as.integer(Sys.getenv("gen_range_end"))

library("openxlsx")
library("plyr")

vcf.colnames <- c("CHROM",
                  "POS",
                  "ID",
                  "REF",
                  "ALT",
                  "QUAL",
                  "FILTER",
                  "INFO",
                  "FORMAT",
                  "SAMPLE")

## Medaka
format.medaka.vcf <- function() {
  # Load the vcf file
  medaka.vcf <- read.table(medaka.file, stringsAsFactors = F)
  colnames(medaka.vcf) <- vcf.colnames
  
  # Remove empty ID column
  medaka.vcf <- subset(medaka.vcf, select = -c(ID))
  
  # Filter rows
  medaka.df <- medaka.vcf[which(
    medaka.vcf$CHROM == chromosome &
      medaka.vcf$POS >= startPos &
      medaka.vcf$POS <= endPos &
      medaka.vcf$FILTER == "PASS"
  ), ]
  
  # check in any positions remain and return if none
  if (nrow(medaka.df) == 0) {
    return(NULL)
  }
  
  # Return the df
  medaka.df
}

# Wrap the function in tryCatch in case the file is empty
medaka.df <- tryCatch(format.medaka.vcf(), error= function(c) {
  return (NULL)
})

## Sniffles
format.sniffles.vcf <- function() {
  sniffles.vcf <- read.table(sniffles.file, stringsAsFactors = F)
  colnames(sniffles.vcf) <- vcf.colnames
  
  # Remove empty ID column
  sniffles.vcf <- subset(sniffles.vcf, select = -c(ID))
  
  # Keep only rows that are relevant to the chr and positions of interest
  sniffles.vcf <-
    sniffles.vcf[which(sniffles.vcf[, "CHROM"] == chromosome), ]
  sniffles.vcf <-
    sniffles.vcf[which(sniffles.vcf[, "POS"] >= startPos &
                         sniffles.vcf[, "POS"] <= endPos), ]
  
  # check in any positions remain and return if none
  if (nrow(sniffles.vcf) == 0) {
    return(NULL)
  }
  
  # Tidy up the INFO column
  sniffles.info <- sniffles.vcf$INFO
  sniffles.info.list <-
    sapply(sniffles.info, function(x)
      strsplit(x, split = ";", fixed = T))
  
  info.tidy.up <- function(info.list) {
    precision <- info.list[1]
    info.list <- info.list[-1]
    split.info <- sapply(info.list, function(x)
      strsplit(x, "="))
    info.keys <- "PRECISION"
    info.values <- precision
    for (i in seq_along(split.info)) {
      info.keys <- c(info.keys, split.info[[i]][1])
      info.values <- c(info.values, split.info[[i]][2])
    }
    names(info.values) <- info.keys
    
    info.values
  }
  
  sniffles.info.list <- lapply(sniffles.info.list, info.tidy.up)
  
  for (i in seq_along(sniffles.info.list)) {
    if (i == 1) {
      info.df <- data.frame(t(sniffles.info.list[[i]]))
      next
    }
    info.df <-
      rbind.fill(info.df, data.frame(t(sniffles.info.list[[i]])))
  }
  
  
  #bind the INFO column to the table
  row.names(sniffles.vcf) <- NULL
  row.names(info.df) <- NULL
  df <- cbind(sniffles.vcf, info.df)
  
  # Return the final df
  df
}

# Wrap the function in tryCatch in case the file is empty
sniffles.df <- tryCatch(format.sniffles.vcf(), error= function(c) {
  return (NULL)
})

#### Write the output
wb <- createWorkbook(paste0(filename, "_report"))

addWorksheet(wb, "Sniffles")
addWorksheet(wb, "Medaka")

writeData(wb, sheet = 1, sniffles.df)
writeData(wb, sheet = 2, medaka.df)

saveWorkbook(wb, outfile, overwrite = TRUE)
RSCRIPT
}

# Create output directory
mkdir -p $reports_dir

#loop through the files
while read -r i
do

export filename="$(echo $i | cut -d ' ' -f2)"
export medaka_file=$medaka_dir/$filename/round_1.vcf
export sniffles_file=$sniffles_dir/${filename}_sniffles.vcf
export outfile=$reports_dir/${filename}_report.xlsx

filter 

done < $sample_names
