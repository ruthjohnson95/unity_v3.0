#!/usr/bin/env sh 
#$ -cwd
#$ -j y
#$ -l h_data=5G,h_rt=2:00:00,highp
#$ -o ukbb_block_height.log
#$ -t 1-1704:1

#SGE_TASK_ID=100

source /u/local/Modules/default/init/modules.sh
module load python/2.7
module load R 

SNP_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/gwas/snplists
PLINK=/u/home/r/ruthjohn/pasaniucdata/software/plink

for file in `ls $SNP_DIR`
do

    COUNTER=$((COUNTER+1))

    if [[ $COUNTER -eq $SGE_TASK_ID ]]
    then


CHR=$(echo $file | cut -d'.' -f1 | sed 's/[^0-9]*//g')

GWAS_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/gwas
RSID_FILE=${GWAS_DIR}/assoc_chr${CHR}.assoc.linear.snplist
GWAS=${GWAS_DIR}/assoc_chr${CHR}.assoc.linear

# get snplist
tail -n +2 $GWAS | awk '{print $2}' > $RSID_FILE

# start with list of SNPs 
file=$(basename $file)
RSID_FILE=$SNP_DIR/$file

OUTDIR=${GWAS_DIR}
PREFIX=$(basename $RSID_FILE | cut -d'.' -f1,2,3) #chr.bp.bp 
RSID_FILE_CLEAN=${OUTDIR}/${PREFIX}.clean

CHR_GWAS_FILE=${GWAS_DIR}/assoc_chr${CHR}.assoc.linear

PLINK=/u/home/r/ruthjohn/pasaniucdata/software/plink

MAF=0.05

# ref panel
BFILE=/u/project/pasaniuc/pasaniucdata/DATA/UKBiobank/array/allchr.unrelatedbritishqced.mafhwe

# add zscores 
CHR_GWAS_FILE_CLEAN=$CHR_GWAS_FILE.clean
if [ ! -f $CHR_GWAS_FILE_CLEAN ]; then
Rscript clean_1.R $CHR_GWAS_FILE $CHR_GWAS_FILE_CLEAN
fi

# filter SNPs
$PLINK --allow-no-sex --biallelic-only --bfile $BFILE --maf $MAF --chr $CHR --extract $RSID_FILE --out $RSID_FILE_CLEAN  --write-snplist

# compute LD
RSID_FILE_CLEAN=${OUTDIR}/${PREFIX}.clean.snplist
$PLINK --allow-no-sex --biallelic-only --bfile $BFILE --maf $MAF --chr $CHR --extract $RSID_FILE_CLEAN --r --matrix --out ${OUTDIR}/${PREFIX}

# filter remaining SNPs
GWAS_LOCI=${OUTDIR}/${PREFIX}.loci
Rscript filter_by_snps.R $CHR_GWAS_FILE_CLEAN $RSID_FILE_CLEAN $GWAS_LOCI

SCRIPT_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/scripts
SRC_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/src

SIM_NAME=${PREFIX}
N=337205

ITS=500
SEED=2018

LD_FILE=${OUTDIR}/${PREFIX}.ld 
LD_HALF_FILE=${OUTDIR}/${PREFIX}.half_ld

# check to see if file already exists 
if [ ! -f $LD_HALF_FILE ]; then
    python $SCRIPT_DIR/half_ld.py --ld_file $LD_FILE  --ld_out $LD_HALF_FILE
fi

# convert betas to beta_std if not already 
BETA_STD=$(head -n 1 $GWAS_LOCI | grep "BETA_STD")
#if [ -z "$BETA_STD" ]
#then
      Rscript $SCRIPT_DIR/0_zscore_to_betas.R $GWAS_LOCI
#fi

GWAS_LOCI=$GWAS_LOCI.clean
BETA_STD_I=$(head -n1 $GWAS_LOCI | grep "BETA_STD_I")

#if [ -z "$BETA_STD_I" ]
#then
    # transform betas 
    python $SCRIPT_DIR/transform_betas.py --gwas_file $GWAS_LOCI --ld_file $LD_FILE
#fi 

OUTDIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/results_maf_0.01
mkdir -p $OUTDIR


python $SRC_DIR/unity_v3_block.py --seed $SEED  --N $N --id $SIM_NAME --its $ITS --ld_half_file $LD_HALF_FILE --gwas_file $GWAS_LOCI  --outdir $OUTDIR  --dp 'y' --full 'y' 

fi

done