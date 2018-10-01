#!/usr/bin/env bash

#$ -cwd
#$ -j y
#$ -l h_data=10G,h_rt=6:00:00,highp
#$ -o unity_v3_block_chr10.log
#$ -t 1-85:1

#SGE_TASK_ID=1

source /u/local/Modules/default/init/modules.sh
module load python/2.7

sim_yaml=$1

if [ -z "$sim_yaml" ]
then
    sim_yaml="sim.yaml"
fi 

# parse yaml file 
SIM_NAME=$(cat $sim_yaml | grep "NAME" | cut -d':' -f2 | tr -d " \t\n\r" )
H_GWAS=$(cat $sim_yaml | grep "H GWAS" | cut -d':' -f2 | tr -d " \t\n\r" )
H_SNP=$(cat $sim_yaml | grep "H SNP" | cut -d':' -f2 | tr -d " \t\n\r" )
P_SIM=$(cat $sim_yaml | grep "P SIM" | cut -d':' -f2 | tr -d " \t\n\r" )
N=$(cat $sim_yaml | grep "SAMPLE SIZE" | cut -d':' -f2 | tr -d " \t\n\r" )
OUT_DIR=$(cat $sim_yaml | grep "OUTDIR" | cut -d':' -f2 | tr -d " \t\n\r" )
LD_LIST=$(cat $sim_yaml | grep "LD LIST" | cut -d':' -f2 | tr -d " \t\n\r" )
RSID_LIST=$(cat $sim_yaml | grep "RSID LIST" | cut -d':' -f2 | tr -d " \t\n\r" )
LD_DIR=$(cat $sim_yaml | grep "LD DIR" | cut -d':' -f2 | tr -d " \t\n\r" )
RSID_DIR=$(cat $sim_yaml | grep "RSID DIR" | cut -d':' -f2 | tr -d " \t\n\r" )
M=$(cat $sim_yaml | grep "NUM SNPS" | cut -d':' -f2 | tr -d " \t\n\r" )
SEED=$(cat $sim_yaml | grep "SEED" | cut -d':' -f2 | tr -d " \t\n\r" )
PLINK=$(cat $sim_yaml | grep "PLINK" | cut -d':' -f2 | tr -d " \t\n\r" )
REF_PATH=$(cat $sim_yaml | grep "REF BIM" | cut -d':' -f2 | tr -d " \t\n\r")

# make simulation output dir 
SIMDIR=$OUT_DIR'/'$SIM_NAME
mkdir -p $SIMDIR

# make header 
echo "- - - - - - - - - - UNITY v3.0  - - - - - - - - -"
echo "NAME: "$SIM_NAME
echo "H SIM: "$H_GWAS
echo "P SIM: "$P_SIM
echo "N: "$N

echo "Outputing results to directory: "$SIMDIR

echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"


    for rsid_file in `cat $RSID_LIST`
    do
	COUNTER=$((COUNTER+1))

	if [[ $COUNTER -eq $SGE_TASK_ID ]]
	then 

	DATE=`date '+%Y-%m-%d %H:%M:%S'`
	echo $DATE" Extracting CHR/BP information for snps: "$rsid_file
	snp_list=$RSID_DIR/$rsid_file
	file_prefix="${rsid_file%.*}"
	CHR=$(echo $file_prefix | cut -d'.' -f1 | sed 's/[^0-9]*//g' )
	$PLINK --bfile $REF_PATH.$CHR --extract $snp_list --make-just-bim --biallelic-only --out $SIMDIR/$file_prefix

# simulate gwas effects
PREFIX=$(echo $rsid_file | cut -d'.' -f1,2,3)
GWAS_FILE=$SIMDIR/$PREFIX.gwas
LD_FILE=$LD_DIR/$PREFIX.ld.gz

# 1/2 LD 
LD_HALF_DIR=$LD_DIR'_half'
mkdir -p $LD_HALF_DIR

python scripts/transform_betas.py --gwas_file $GWAS_FILE --ld_file $LD_FILE 
LD_HALF_FILE=$LD_HALF_DIR/$PREFIX.half_ld 

python scripts/half_ld.py --ld_file $LD_FILE --ld_half_dir $LD_HALF_DIR 

# run inference 
ITS=1000
python src/unity_v3_block.py --seed $SEED --H_gwas $H_GWAS --H_snp $H_SNP --id $PREFIX --ld_half_file $LD_HALF_FILE --gwas_file $GWAS_FILE --outdir $SIMDIR --its $ITS 

fi

done

fi 