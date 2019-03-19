#!/usr/bin/env bash

RESULTS_DIR=$1

if [ -z "$RESULTS_DIR" ]
then
    # use default results dir 
    RESULTS_DIR=/u/flashscratch/r/ruthjohn/ukbb_bmi_exp/results_maf_0.05
fi

GWAS_DIR=$(dirname $RESULTS_DIR)/gwas_chr_block_2

# results file per run 
RESULT_FILE=${RESULTS_DIR}/summary.txt 

echo "chr_N chr locus M p sd_p sigma_g sd_sigma_g sigma_e sd_sigma_e" > $RESULT_FILE

# only look at log files 
for file in `ls -v $RESULTS_DIR/chr*.log`
do
    CHR=$(basename $file | cut -d'.' -f1)
    CHR_N=$(basename $file | cut -d'.' -f1 | sed 's/[^0-9]*//g')
    LOCUS=$(basename $file | cut -d'.' -f2,3)
    P=$(cat $file | grep "Estimate p:" | cut -d' ' -f3)
    P_SD=$(cat $file |grep "SD p:" | cut -d' ' -f3)
    
    SIGMA_G=$(cat $file |grep "Estimate sigma_g:" | cut -d' ' -f3)
    SIGMA_G_SD=$(cat $file |grep "SD sigma_g:" | cut -d' ' -f3)

    SIGMA_E=$(cat $file |grep "Estimate sigma_e:" | cut -d' ' -f3)
    SIGMA_E_SD=$(cat $file |grep "SD sigma_e:" | cut -d' ' -f3)
    
    # get number of SNPS by looking at LD matrix
    M=$(wc -l ${GWAS_DIR}/$CHR.$LOCUS.ld | cut -d' ' -f1)

    echo $CHR_N $CHR $LOCUS $M $P $P_SD $SIGMA_G $SIGMA_G_SD $SIGMA_E $SIGMA_E_SD >> $RESULT_FILE

done