#!/usr/bin/env sh
#$ -cwd
#$ -j y
#$ -l h_data=20G,h_rt=06:00:00,highp
#$ -o trait.12mb.log
#$ -t 1-245:1

#SGE_TASK_ID=137

TRAIT=$1
BLOCK_SIZE=12mb

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly
SRC_DIR=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/src
SCRIPT_DIR=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/scripts

TRAIT_DIR=${MASTER_PATH}/${TRAIT}
LOCI_DIR=${TRAIT_DIR}/${BLOCK_SIZE}
META_DIR=${MASTER_PATH}/meta_data
CSV_FILE=${META_DIR}/${TRAIT}.${BLOCK_SIZE}.csv
BIM_FILE=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/misc/filter4.bim
SUMSTATS=/u/project/pasaniuc/kangchen/projects/ukbb_local_h2g/out/sumstats/${TRAIT}.sumstats
LD_DIR=/u/project/pasaniuc/kangchen/projects/ukbb_local_h2g/out/ld

source /u/local/Modules/default/init/modules.sh
module load python/2.7

i=1
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