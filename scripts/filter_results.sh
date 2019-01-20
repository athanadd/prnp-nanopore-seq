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
.libPaths(Sys.getenv("libs_path"))

sniffles.file <- Sys.getenv("sniffles_file")
nanopolish.file <- Sys.getenv("nanopolish_file")
filename <- Sys.getenv("filename")
outfile <- Sys.getenv("outfile")
chromosome <- Sys.getenv("gen_range_chr")
startPos <- as.integer(Sys.getenv("gen_range_start"))
endPos <- as.integer(Sys.getenv("gen_range_end"))

library(vcfR)
library(plyr)
library(openxlsx)

quality.cutoff <- 10000 # Nanopolish quality cutoff filter
sup.fr.cutoff <- 0.5 # Nanopolish mean selected frequency
sup.fr.range <- 0.1 # Nanopolish range of accepted frequencies


# Format the file to a more readable data frame
  format.sniffles.vcf <- function(vcf, chromosome, startPos, endPos) {
    
    # Load the vcf file
    vcf <- read.vcfR(vcf, verbose = F)
    
    # Keep the slot with the variants info in a df
    vcf <- data.frame(vcf@fix, stringsAsFactors = F)
    
    # Fix data types because they are not automatically detected
    vcf <- transform(vcf,
                     POS = as.numeric(POS),
                     QUAL = as.numeric(QUAL))
    
    # Select only rows that are relevant to the chr and positions of interest
    vcf <- vcf[which(vcf[,"CHROM"] == chromosome),]
    vcf <- vcf[which(vcf[,"POS"] >= startPos & vcf[,"POS"] <= endPos),]
    
    # check in any positions remain and return if none
    if (nrow(vcf) == 0) {
      return(NULL)
    }
    
    # Tidy up the INFO column
    vcf.info <- vcf$INFO
    vcf.info.list <- sapply(vcf.info, function(x) strsplit(x, split = ";"))
    
    info.tidy.up <- function(info.list) {
      precision <- info.list[1]
      info.list <- info.list[-1]
      split.info <- sapply(info.list, function(x) strsplit(x, "="))
      info.keys <-"PRECISION"
      info.values <- precision
      for(i in seq_along(split.info)) {
        info.keys <- c(info.keys, split.info[[i]][1])
        info.values <- c(info.values, split.info[[i]][2])
      }
      names(info.values) <- info.keys
      
      info.values
    }
    
    vcf.info.list <- lapply(vcf.info.list, info.tidy.up)
    
    for (i in seq_along(vcf.info.list)){
      if (i == 1) {
        info.df <- data.frame(t(vcf.info.list[[i]]))
        next
      }
      info.df <- rbind.fill(info.df, data.frame(t(vcf.info.list[[i]])))
    }
    
    #bind the INFO column to the table
    row.names(vcf) <- NULL
    row.names(info.df) <- NULL
    df<- cbind(subset(vcf, select=-c(INFO)), info.df)
    
    # Return the final df
    df
  }
  
  sniffles.df <- format.sniffles.vcf(sniffles.file, chromosome, startPos, endPos)
  
  ##### NANOPOLISH
  options(stringsAsFactors = FALSE)
  
  # Format the file to a more readable data frame
  format.nanopolish.vcf <- function(vcf, chromosome, startPos, endPos) {
    
    # Load the vcf file
    vcf <- read.vcfR(vcf, verbose = F)
    
    # Keep the slot with the variants info in a df
    vcf <- data.frame(vcf@fix)
    
    # Fix data types because they are not automatically detected
    vcf <- transform(vcf,
                     POS = as.numeric(POS),
                     QUAL = as.numeric(QUAL))
    
    # Select only rows that are relevant to the chr and positions of interest
    vcf <- vcf[which(vcf[,"CHROM"] == chromosome),]
    vcf <- vcf[which(vcf[,"POS"] >= startPos & vcf[,"POS"] <= endPos),]
    
    if(nrow(vcf) == 0) {
      return(NULL)
    }
    
    # Tidy up the INFO column
    vcf.info <- vcf$INFO
    vcf.info.list <- sapply(vcf.info, function(x) strsplit(x, split = ";"))
    
    info.tidy.up <- function(info.list) {
      split.info <- sapply(info.list, function(x) strsplit(x, "="))
      info.keys <- c()
      info.values <- c()
      for(i in seq_along(split.info)) {
        info.keys <- c(info.keys, split.info[[i]][1])
        info.values <- c(info.values, split.info[[i]][2])
      }
      names(info.values) <- info.keys
      
      info.values
    }
    
    vcf.info.list <- lapply(vcf.info.list, info.tidy.up)
    
    for (i in seq_along(vcf.info.list)){
      if (i == 1) {
        info.df <- data.frame(t(vcf.info.list[[i]]))
        next
      }
      info.df <- rbind.fill(info.df, data.frame(t(vcf.info.list[[i]])))
    }
    
    #bind the INFO column to the table
    row.names(vcf) <- NULL
    row.names(info.df) <- NULL
    df<- cbind(subset(vcf, select=-c(INFO)), info.df)
    
    # Fix data types
    df <- transform(df,
                    BaseCalledReadsWithVariant = as.numeric(BaseCalledReadsWithVariant),
                    BaseCalledFraction = as.numeric(BaseCalledFraction),
                    TotalReads = as.numeric(TotalReads),
                    AlleleCount = as.numeric(AlleleCount),
                    SupportFraction = as.numeric(SupportFraction))
    
    # Return the final df
    df
  }
  
  nanopolish.df <- format.nanopolish.vcf(nanopolish.file, chromosome, startPos, endPos)
  
  
  # Filter the files based on quality and support fraction
  filter.nanopolish <- function(nanopolish.df, quality.cutoff, sup.fr.cutoff, sup.fr.range) {
    
    if (is.null(nanopolish.df)) {
      return (NULL)
    }
    
    # Filter based on quality
    nanopolish.df <- nanopolish.df[which(nanopolish.df[,"QUAL"] > quality.cutoff),]
    
    # Filter based on support fraction
    nanopolish.df <- nanopolish.df[which(
      (nanopolish.df[,"SupportFraction"] > (sup.fr.cutoff - sup.fr.range) &
         nanopolish.df[,"SupportFraction"] < (sup.fr.cutoff + sup.fr.range)) |
        nanopolish.df[,"SupportFraction"] > 0.9
    ),]
    
    # Reset row names
    row.names(nanopolish.df) <- NULL
    
    # Return the filtered vcf
    nanopolish.df
  }
  
  nanopolish.filtered.df <- filter.nanopolish(nanopolish.df, quality.cutoff, sup.fr.cutoff, sup.fr.range)
  
  
  #### Write the output
  wb <- createWorkbook(paste0(filename, "_report"))
  
  addWorksheet(wb, "Sniffles")
  addWorksheet(wb, "Nanopolish")
  addWorksheet(wb, "Nanopolish_filtered")
  
  writeData(wb, sheet = 1, sniffles.df)
  writeData(wb, sheet = 2, nanopolish.df)
  writeData(wb, sheet = 3, nanopolish.filtered.df)
  
  saveWorkbook(wb, outfile, overwrite = TRUE)

RSCRIPT
}

# Create output directory
mkdir -p $DIR/reports

# loop through the files
while IFS=$'\t' read -r i
do

export filename="$(echo $i | cut -d ' ' -f2)"
export nanopolish_file=${nanopolish_variants_dir}/${filename}_nanopolish_variants.vcf
export sniffles_file=${sniffles_variants_dir}/${filename}_sniffles.vcf
export outfile=$DIR/reports/${filename}_report.xlsx

filter 

done < $sample_names
