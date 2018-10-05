#!/usr/bin/env bash

#$ -cwd
#$ -j y
#$ -l h_data=10G,h_rt=6:00:00,highp
#$ -o unity_v3_block_chr10.log

SGE_TASK_ID=1 

source /u/local/Modules/default/init/modules.sh
module load python/2.7

sim_yaml=$1

if [ -z "$sim_yaml" ]
then
    sim_yaml="test_dp.yaml"
fi 

# parse yaml file 
SIM_NAME=$(cat $sim_yaml | grep "SIM NAME" | cut -d':' -f2 | tr -d " \t\n\r" )
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
echo "- - - - - - - - - - UNITY v1.0 simulation - - - - - - - - -"
echo "SIM NAME: "$SIM_NAME
echo "H SIM: "$H_GWAS
echo "P SIM: "$P_SIM
echo "N: "$N

if [ "$LD_LIST" = "NA" ] && [ "$RSID_LIST" = "NA" ]
then # no LD 
    echo "NUM SNPS: "$M
    echo "Not simulating with LD"
else
    echo "LD LIST: "$LD_LIST
    echo "RSID LIST: "$RSID_LIST
fi

echo "Outputing simulated gwas to directory: "$SIMDIR

echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"


# checks if LD_LIST and RSID_LIST is not NA 
if [ "$LD_LIST" = "NA" ] && [ "$RSID_LIST" = "NA" ]
then
    # simulate without LD 
    echo "no LD"
else
    # get chr/BP from plink
    for rsid_file in `cat $RSID_LIST`
    do

	DATE=`date '+%Y-%m-%d %H:%M:%S'`
	echo $DATE" Extracting CHR/BP information for snps: "$rsid_file
	snp_list=$RSID_DIR/$rsid_file
	file_prefix="${rsid_file%.*}"
	CHR=$(echo $file_prefix | cut -d'.' -f1 | sed 's/[^0-9]*//g' )
	$PLINK --bfile $REF_PATH.$CHR --extract $snp_list --make-just-bim --biallelic-only --out $SIMDIR/$file_prefix

# simulate gwas effects
SEED=$SGE_TASK_ID
python scripts/simulate.py --sim_name $SIM_NAME --h_gwas $H_GWAS --h_snp $H_SNP --p_sim $P_SIM --N $N --rsid_list $RSID_LIST --ld_list $LD_LIST --outdir $SIMDIR --bim_dir $SIMDIR --ld_dir $LD_DIR --seed $SEED 

# gwas/ld files 
PREFIX=$(echo $rsid_file | cut -d'.' -f1,2,3)
GWAS_FILE=$SIMDIR/$PREFIX.gwas
LD_FILE=$LD_DIR/$PREFIX.ld


# 1/2 LD 
LD_HALF_DIR=$LD_DIR'_half'
mkdir -p $LD_HALF_DIR

python scripts/transform_betas.py --gwas_file $GWAS_FILE --ld_file $LD_FILE 
LD_HALF_FILE=$LD_HALF_DIR/$PREFIX.half_ld 

python scripts/half_ld.py --ld_file $LD_FILE --ld_half_dir $LD_HALF_DIR 

# run inference 
ITS=100
python src/unity_v3_dp.py --seed $SEED --H_gwas $H_GWAS --H_snp $H_SNP --id $PREFIX --ld_half_file $LD_HALF_FILE --gwas_file $GWAS_FILE --outdir $SIMDIR --its $ITS --dp 'n'


done

fi 