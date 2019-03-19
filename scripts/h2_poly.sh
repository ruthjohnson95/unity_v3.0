#!/usr/bin/env sh
#$ -cwd
#$ -j y
#$ -l h_data=25G,h_rt=00:30:00,highp
#$ -o height.6mb.log
#$ -t 1-470:1

#SGE_TASK_ID=27

TRAIT=height
BLOCK_SIZE=6mb

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly
SRC_DIR=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/src
SCRIPT_DIR=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/scripts

TRAIT_DIR=${MASTER_PATH}/${TRAIT}
LOCI_DIR=${TRAIT_DIR}/${BLOCK_SIZE}

CSV_FILE=${LOCI_DIR}/height.${BLOCK_SIZE}.csv
BIM_FILE=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/misc/filter4.bim
SUMSTATS=/u/project/pasaniuc/kangchen/projects/ukbb_local_h2g/out/sumstats/height.sumstats
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
    CHR=$(echo $row | cut -d',' -f1)
    START=$(echo $row |cut -d',' -f2)
    STOP=$(echo $row |cut -d',' -f3)
    H2=$(echo $row |cut -d',' -f11)
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