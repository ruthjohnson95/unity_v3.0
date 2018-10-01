#!/bin/sh

# path to PLINK executable
PLINK=$1

# minor allele frequency 
MAF=0.05

PROJECT_DIR=$2

# dir with lists of rsids 
DATA_DIR=${PROJECT_DIR}/all_chr_1KG_maf_${MAF}/rsID_files

# output dir with final LD files 
OUT_DIR=${PROJECT_DIR}/all_chr_1KG_maf_${MAF}/ld_files

# bed file listing LD blocks
LD_BLOCKS=/u/project/eeskin/pasaniuc/pasaniucdata/gleb_kathy_ruthie/pickrell_blocks/pickrell.blocks.bed.reformat

mkdir -p $OUT_DIR

# send off 8 blocks per job
for n in {1..8}; do
	i=$((I+n))
	NAME=$(awk -v var=$i 'NR==var{print $NF}' $LD_BLOCKS)
	echo $NAME
	FILE=${DATA_DIR}/${NAME}.snplist

	CHR=$(echo $NAME | cut -d'.' -f1 |  sed 's/[^0-9]*//g')

	# 1000G files
	PLINK_DATA=/u/project/pasaniuc/kburch/direct/simulation/data/1KG_plink_files/1000G.EUR.QC.$CHR

	$PLINK --noweb --allow-no-sex --bfile $PLINK_DATA --maf $MAF --chr $CHR  --extract $FILE --r --matrix --out ${OUT_DIR}/${NAME}
done

