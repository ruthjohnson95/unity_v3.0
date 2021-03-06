#!/usr/bin/env sh 
#$ -cwd
#$ -j y
#$ -l h_data=60G,h_rt=12:00:00,highp
#$ -o ukbb_height_chr_block.log
#$ -t 1-2:1

#SGE_TASK_ID=1

source /u/local/Modules/default/init/modules.sh
module load python/2.7
module load R 

TRAIT=height

SNP_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/gwas/snplists_chr
GWAS_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp/gwas

mkdir -p $GWAS_DIR 

PLINK=/u/home/r/ruthjohn/pasaniucdata/software/plink

for file in `ls -v $SNP_DIR/chr*.snplists`
do

    COUNTER=$((COUNTER+1))

    if [[ $COUNTER -eq $SGE_TASK_ID ]]
    then


CHR=$(echo $file | cut -d'.' -f1 | sed 's/[^0-9]*//')
CHR_N=$(echo $file | cut -d'.' -f1 | sed 's/[^0-9]*//g')

RSID_FILE=${GWAS_DIR}/assoc_chr${CHR_N}.assoc.linear.snplist
GWAS=${GWAS_DIR}/assoc_chr${CHR_N}.assoc.linear

# get snplist
tail -n +2 $GWAS | awk '{print $2}' > $RSID_FILE

# start with list of SNPs 
file=$(basename $file)
RSID_FILE=$SNP_DIR/$file

OUTDIR=${GWAS_DIR}
PREFIX=$(basename $RSID_FILE | cut -d'.' -f1,2,3) #chr.bp.bp 
RSID_FILE_CLEAN=${OUTDIR}/${PREFIX}.clean

CHR_GWAS_FILE=${GWAS_DIR}/assoc_chr${CHR_N}.assoc.linear

MAF=0.05

# ref panel
BFILE=/u/project/pasaniuc/pasaniucdata/DATA/UKBiobank/array/allchr.unrelatedbritishqced.mafhwe

# add zscores 
CHR_GWAS_FILE_CLEAN=$CHR_GWAS_FILE.clean

Rscript clean_1.R $CHR_GWAS_FILE $CHR_GWAS_FILE_CLEAN

# filter SNPs

# MHC
MHC_START=28000000
MHC_END=33500000

if [ $CHR_N -eq 6 ]
then
    echo "CHR6"
  ####  $PLINK --allow-no-sex --biallelic-only --bfile $BFILE --maf $MAF --chr $CHR_N --extract $RSID_FILE --out $RSID_FILE_CLEAN  --write-snplist --exclude-snp --window --from-bp $MHC_START --to-bp $MHC_END 
else
    echo ""
####    $PLINK --allow-no-sex --biallelic-only --bfile $BFILE --maf $MAF --chr $CHR_N --extract $RSID_FILE --out $RSID_FILE_CLEAN  --write-snplist
fi


# compute LD
RSID_FILE_CLEAN=${OUTDIR}/${PREFIX}.clean.snplist
######$PLINK --allow-no-sex --biallelic-only --bfile $BFILE --maf $MAF --chr $CHR_N --extract $RSID_FILE_CLEAN --r --matrix --out ${OUTDIR}/${PREFIX}

# filter remaining SNPs
GWAS_LOCI=${OUTDIR}/${PREFIX}.loci
Rscript filter_by_snps.R $CHR_GWAS_FILE_CLEAN $RSID_FILE_CLEAN $GWAS_LOCI

SCRIPT_DIR=/u/flashscratch/r/ruthjohn/ukbb_${TRAIT}_exp/scripts
SRC_DIR=/u/flashscratch/r/ruthjohn/ukbb_${TRAIT}_exp/src
SIM_NAME=${PREFIX}
N=337205

ITS=100
SEED=2018

LD_FILE=${OUTDIR}/${PREFIX}.ld 
LD_HALF_FILE=${OUTDIR}/${PREFIX}.half_ld

# LD half 
    python $SCRIPT_DIR/half_ld.py --ld_file $LD_FILE  --ld_out $LD_HALF_FILE

# convert betas to beta_std if not already 
      Rscript $SCRIPT_DIR/0_zscore_to_betas.R $GWAS_LOCI

GWAS_LOCI=$GWAS_LOCI.clean
BETA_STD_I=$(head -n1 $GWAS_LOCI | grep "BETA_STD_I")

# transform betas 
python $SCRIPT_DIR/transform_betas.py --gwas_file $GWAS_LOCI --ld_file $LD_FILE

# DONE! 

fi

done