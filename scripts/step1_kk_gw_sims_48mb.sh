#!/usr/bin/env sh
#$ -cwd
#$ -j y
#$ -l h_data=48G,h_rt=06:00:00,highp
#$ -o h2_chr22_sims_48mb.log
#$ -t 1-200:1

# This step puts ld blocks in 6mb/12mb/etc folder that is to be shared for all sumstats. Additionally grabs loci for each simulation and block which is stored in /results/trait/block

# number of tasks corresponds to how many sims

#SGE_TASK_ID=1

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0
SRC_DIR=${MASTER_PATH}/src
SCRIPT_DIR=${MASTER_PATH}/scripts

META_DIR=${MASTER_PATH}/sims_kk_gw/meta_data
CSV_DIR=${META_DIR}/local_h2g_ests
SUMSTATS_DIR=${MASTER_PATH}/sims_kk_gw/sumstats/chr22
LD_DIR=/u/project/pasaniuc/pasaniucdata/kathy_kangcheng/ukbb_33297_bogdan/ld
BIM_FILE=/u/home/r/ruthjohn/pasaniucdata/DATA/UKBiobank/array/allchr.unrelatedbritishqced.mafhwe.bim

source /u/local/Modules/default/init/modules.sh
module load python/2.7

for trait in cau_ratio_0.01_hsq_0.25_maf_0.0_ld_0.0_range_0.0_1.0 cau_ratio_0.01_hsq_0.25_maf_0.75_ld_1.0_range_0.0_1.0
do

    TRAIT_DIR=${MASTER_PATH}/sims_kk_gw/results/$trait

    for block in 48mb
    do

	     LOCI_DIR=${TRAIT_DIR}/$block
	     mkdir -p $LOCI_DIR
	     CSV_FILE=${CSV_DIR}/${trait}.${block}.csv

	     i=1 # skip header row
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
            H2=$(echo $row |cut -d',' -f4)
            SIM_I=$(echo $row |cut -d',' -f5)
            N=337205

            SUMSTATS=${SUMSTATS_DIR}/${trait}_sim_${SIM_I}.sumstats

            # just grab locus
            python ${SCRIPT_DIR}/helper/grab_locus_ld.py \
            --chr $CHR \
            --start $START \
            --stop $STOP \
            --bim $BIM_FILE \
            --sumstats $SUMSTATS \
            --sim_i $SIM_I \
            --ld_dir $LD_DIR \
            --outdir $LOCI_DIR

            # run!
            PREFIX=chr_${CHR}_start_${START}_stop_${STOP}_sim_${SIM_I}
            LOCUS_FILE=${LOCI_DIR}/${PREFIX}.loci
            LD_HALF_FILE=${LOCI_DIR}/${PREFIX}.half_ld.npy
            M=$(wc -l $LOCUS_FILE | cut -d' ' -f1)
            let "M = $M -1" # remove header line from count

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

done
