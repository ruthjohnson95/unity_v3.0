#!/bin/sh

# full path to snplist 
RSID_FILE=$1
NAME_PREFIX="${RSID_FILE%.*}"

# full path to plink executable
PLINK=$2
REF_PANEL=$3
OUTDIR=$5
MAF=$4


# get chromosome number 
CHR=$(echo $RSID_FILE | cut -d'.' -f1 |  sed 's/[^0-9]*//g')

# 1000G ref panel 
BFILE=$REF_PANEL'.'$CHR

# compute LD 
$PLINK --allow-no-sex --bfile $BFILE --maf $MAF --chr $CHR --extract $RSID_FILE --r --matrix --out ${OUTDIR}/${NAME_PREFIX}
