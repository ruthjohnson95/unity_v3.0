#!/usr/bin/env sh
#$ -cwd
#$ -j y
#$ -l h_data=10G,h_rt=02:00:00,highp
#$ -o h2_chr22_sims.log
#$ -t 1-200:1

# number of tasks corresponds to how many sims

#SGE_TASK_ID=1

TRAIT=$1
BLOCK_SIZE=6mb

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/
SRC_DIR=${MASTER_PATH}/src
SCRIPT_DIR=${MASTER_PATH}/scripts

TRAIT_DIR=${MASTER_PATH}/sims_kk_gw
LOCI_DIR=${TRAIT_DIR}/results
META_DIR=${TRAIT_DIR}/meta_data
CSV_FILE=${META_DIR}/${TRAIT}.${BLOCK_SIZE}.csv
BIM_FILE=/u/home/r/ruthjohn/pasaniucdata/DATA/UKBiobank/array/allchr.unrelatedbritishqced.mafhwe.bim

SUMSTATS=/u/project/pasaniuc/kangchen/projects/ukbb_local_h2g/out/sumstats/${TRAIT}.sumstats
LD_DIR=/u/project/pasaniuc/kangchen/projects/ukbb_local_h2g/out/ld

source /u/local/Modules/default/init/modules.sh
module load python/2.7

for block in 6mb 12mb 24mb 48mb
do

i=1 # skip header row
while read row
do

    test $i -eq 1 && ((i=i+1)) && continue

    COUNTER=$((COUNTER+1))
    if [[ $COUNTER -eq $SGE_TASK_ID ]]
    then
	
    # parse for metadata
    CHR=$(echo $row | cut -d',' -f2)
    START=$(echo $row |cut -d',' -f3)
    STOP=$(echo $row |cut -d',' -f4)
    H2=$(echo $row |cut -d',' -f9)
    M=$(echo $row |cut -d',' -f5)
    N=$(echo $row |cut -d',' -f6)

    python ${SCRIPT_DIR}/grab_locus_ld.py \
	--chr $CHR \
	--start $START \
	--stop $STOP \
	--bim $BIM_FILE \
	--sumstats $SUMSTATS \
	--ld_dir $LD_DIR \
	--outdir $LOCI_DIR

    # run! 
    PREFIX=chr_${CHR}_start_${START}_stop_${STOP}
    LOCUS_FILE=${LOCI_DIR}/${PREFIX}.loci
    LD_HALF_FILE=${LOCI_DIR}/${PREFIX}.half_ld.npy
    
    ITS=250
    python ${SRC_DIR}/main_new.py \
            --seed $SGE_TASK_ID \
            --N $N \
            --id $PREFIX \
            --its $ITS \
            --ld_half_file $LD_HALF_FILE \
            --gwas_file $LOCUS_FILE  \
            --outdir $LOCI_DIR \
	    --H_gw $H2 \
            --M_gw $M \
	    --dp
    sleep 300

   fi
done < $CSV_FILE

done