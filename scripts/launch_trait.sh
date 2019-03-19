#!/usr/bin/env sh

MASTER_DIR=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly
TRAIT_LIST=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/trait_list
SCRIPT_DIR=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/scripts

while read TRAIT
do
    mkdir -p ${MASTER_DIR}/$TRAIT
    mkdir -p ${MASTER_DIR}/$TRAIT/6mb
    mkdir -p ${MASTER_DIR}/$TRAIT/12mb
    mkdir -p ${MASTER_DIR}/$TRAIT/24mb
    mkdir -p ${MASTER_DIR}/$TRAIT/48mb

#    bash ${SCRIPT_DIR}/h2_poly_6mb.sh $TRAIT
#    bash ${SCRIPT_DIR}/h2_poly_12mb.sh $TRAIT
#    bash ${SCRIPT_DIR}/h2_poly_24mb.sh $TRAIT
#    bash ${SCRIPT_DIR}/h2_poly_48mb.sh $TRAIT

    qsub ${SCRIPT_DIR}/h2_poly_6mb.sh $TRAIT
#    qsub ${SCRIPT_DIR}/h2_poly_12mb.sh $TRAIT
#    qsub ${SCRIPT_DIR}/h2_poly_24mb.sh $TRAIT
#   qsub ${SCRIPT_DIR}/h2_poly_48mb.sh $TRAIT

done < $TRAIT_LIST