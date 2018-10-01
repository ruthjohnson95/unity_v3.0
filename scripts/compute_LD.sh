#!/bin/sh

# full path to snplist 
RSID_FILE=$1 
RSID_FILE_BASE=$(basename $RSID_FILE) 
NAME_PREFIX="${RSID_FILE_BASE%.*}"

# full path to plink executable
PLINK=$2
REF_PANEL=$3
OUTDIR=$4
MAF=$5


# get chromosome number 
CHR=$6

# 1000G ref panel 
BFILE=$REF_PANEL'.'$CHR

# compute LD 
$PLINK --allow-no-sex --bfile $BFILE --maf $MAF --chr $CHR --extract $RSID_FILE --r --matrix --out ${OUTDIR}/${NAME_PREFIX}
