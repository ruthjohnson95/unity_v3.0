#!/usr/bin/env sh

source /u/local/Modules/default/init/modules.sh
module load python/2.7

sim_yaml=$1

if [ -z "$sim_yaml" ]
then
    sim_yaml="chr10.yaml"
fi

# parse yaml file
SIM_NAME=$(cat $sim_yaml | grep "SIM NAME" | cut -d':' -f2 | tr -d " \t\n\r" )
H_SIM=$(cat $sim_yaml | grep "H SIM" | cut -d':' -f2 | tr -d " \t\n\r" )
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

SIMDIR=$OUT_DIR'/'$SIM_NAME

# assumes gwas blocks have been generated 
LD_HALF_DIR=$SIMDIR/$SIM_NAME'_half_dir'
mkdir -p $LD_HALF_DIR

# transform betas 
python scripts/transform_betas.py --gwas_dir $SIMDIR --ld_dir $LD_DIR

# take 1/2 power of ld 
BLOCKS=1 
python scripts/half_ld.py --ld_dir $LD_DIR --ld_half_dir $LD_HALF_DIR --blocks $BLOCKS

python src/unity_v3.py --seed $SEED --H $H_SIM --N $N --id $SIM_NAME --ld_half_dir $LD_HALF_DIR --gwas_dir $SIMDIR --outdir $SIMDIR --its $ITS