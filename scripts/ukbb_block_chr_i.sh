#!/usr/bin/env sh 
#$ -cwd
#$ -j y
#$ -l h_data=40G,h_rt=12:00:00,highp
#$ -o ukbb_block_height_chr.log

# CHROMOSOME NUMBER
SGE_TASK_ID=2

source /u/local/Modules/default/init/modules.sh
module load python/2.7
module load R 

SNP_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/gwas/snplists_chr
PLINK=/u/home/r/ruthjohn/pasaniucdata/software/plink

for file in `ls $SNP_DIR/*.snplists`
do

    COUNTER=$((COUNTER+1))

    if [[ $COUNTER -eq $SGE_TASK_ID ]]
    then


CHR=$(echo $file | cut -d'.' -f1 | sed 's/[^0-9]*//g')

GWAS_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/gwas
RSID_FILE=${GWAS_DIR}/assoc_chr${CHR}.assoc.linear.snplist
GWAS=${GWAS_DIR}/assoc_chr${CHR}.assoc.linear

# start with list of SNPs 
file=$(basename $file)
RSID_FILE=$SNP_DIR/$file
RSID_FILE_CLEAN=${OUTDIR}/${PREFIX}.clean

OUTDIR=${GWAS_DIR}
PREFIX=$(basename $RSID_FILE | cut -d'.' -f1,2,3) #chr.bp.bp
GWAS_LOCI=${OUTDIR}/${PREFIX}.loci

CHR_GWAS_FILE=${GWAS_DIR}/assoc_chr${CHR}.assoc.linear

PLINK=/u/home/r/ruthjohn/pasaniucdata/software/plink

MAF=0.05

# ref panel
BFILE=/u/project/pasaniuc/pasaniucdata/DATA/UKBiobank/array/allchr.unrelatedbritishqced.mafhwe

SCRIPT_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/scripts
SRC_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/src

SIM_NAME=${PREFIX}
N=337205

ITS=500
SEED=2018

LD_FILE=${OUTDIR}/${PREFIX}.ld 
LD_HALF_FILE=${OUTDIR}/${PREFIX}.half_ld


# Compute half ld 
    python $SCRIPT_DIR/half_ld.py --ld_file $LD_FILE  --ld_out $LD_HALF_FILE


GWAS_LOCI=$GWAS_LOCI.clean
BETA_STD_I=$(head -n1 $GWAS_LOCI | grep "BETA_STD_I")

    # transform betas 
    python $SCRIPT_DIR/transform_betas.py --gwas_file $GWAS_LOCI --ld_file $LD_FILE

OUTDIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/results_chr
mkdir -p $OUTDIR


python $SRC_DIR/unity_v3_block.py --seed $SEED  --N $N --id $SIM_NAME --its $ITS --ld_half_file $LD_HALF_FILE --gwas_file $GWAS_LOCI  --outdir $OUTDIR  --dp 'y' --full 'y' 

fi

done