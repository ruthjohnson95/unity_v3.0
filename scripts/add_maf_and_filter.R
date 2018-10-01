#!/usr/bin/env Rscript

library("optparse")

option_list = list(
  make_option(c("--locus_file"), type="character", default=NULL, 
              help="full path to locus file", metavar="character"),
	      make_option(c("--maf_thresh"), type="double",
              help="MAF cutoff value", metavar="character"),
	      make_option(c("--maf_file"), type="character",
          help="full path to file with maf for each SNP (in same order as SNPs in locus file!)", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# read in command line args 
locus_file <- opt$locus_file 
maf_file <- opt$maf_file 
maf_thresh <- opt$maf_thresh 

# load files 
locus <- read.table(locus_file, header=T, sep=' ')
maf <- read.table(maf_file, header=T)
maf_col <- maf$MAF 

# add maf column to locus file 
locus$FREQ <- maf_col 

# replace NA maf 
locus$FREQ[is.na(locus$FREQ)] <- 0 

# filter by maf 
maf_inds <- which(locus $FREQ >= maf_thresh)
locus <- locus[maf_inds, ]

# save gwas file 
write.table(locus, locus_file, row.names=F, quote=F, sep=' ')


