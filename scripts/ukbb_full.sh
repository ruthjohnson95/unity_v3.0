#!/usr/bin/env sh 
#$ -cwd
#$ -j y
#$ -l h_data=6G,h_rt=5:00:00,highp
#$ -o ukbb_short.log

source /u/local/Modules/default/init/modules.sh
module load python/2.7
module load R 

# calculate LD and half-ld in previous step before running pipeline 

SCRIPT_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/scripts
SRC_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/src

SIM_NAME="ukbb_height"
N=337205
GWAS_FILE=/u/flashscratch/r/ruthjohn/ukbb_height_exp/gwas/assoc_chr22.assoc.linear.clean
OUTDIR=/Users/ruthiejohnson/Development/unity_v3.0/results
ITS=100
SEED=2018

LD_FILE=/u/flashscratch/r/ruthjohn/ukbb_height_exp/gwas/assoc_chr22.assoc.linear.clean.ld
	
LD_HALF_FILE=/u/flashscratch/r/ruthjohn/ukbb_height_exp/gwas/assoc_chr22.assoc.linear.clean.half_ld

# check to see if file already exists 
#if [ ! -f $LD_HALF_FILE ]; then
    python $SCRIPT_DIR/half_ld.py --ld_file $LD_FILE  --ld_out $LD_HALF_FILE
#fi

# convert betas to beta_std if not already 
BETA_STD=$(head -n 1 $GWAS_FILE.txt | grep "BETA_STD")
if [ -z "$BETA_STD" ]
then
      Rscript $SCRIPT_DIR/0_zscore_to_betas.R $GWAS_FILE
fi

GWAS_FILE=$GWAS_FILE.txt 
BETA_STD_I=$(head -n1 $GWAS_FILE | grep "BETA_STD_I")

#if [ -z "$BETA_STD_I" ]
#then
    # transform betas 
    python $SCRIPT_DIR/transform_betas.py --gwas_file $GWAS_FILE --ld_file $LD_FILE
#fi 

mkdir -p $OUTDIR

python $SRC_DIR/unity_v3_block.py --seed $SEED  --N $N --id $SIM_NAME --its $ITS --ld_half_file $LD_HALF_FILE --gwas_file $GWAS_FILE  --outdir $OUTDIR  --dp 'y' --full 'y' 

