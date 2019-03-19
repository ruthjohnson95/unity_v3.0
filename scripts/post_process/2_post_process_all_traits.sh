
TRAIT_LIST=$1

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly
ALL_SUM_FILE=${MASTER_PATH}/SUMMARY/ALL.summary.txt
echo "TRAIT BLOCK CHR START STOP H2 M P_EST P_SD" > $ALL_SUM_FILE

while read TRAIT
do
    echo $TRAIT 
    TRAIT_DIR=${MASTER_PATH}/${TRAIT}
    SUM_FILE=${TRAIT_DIR}/${TRAIT}.summary.txt
    tail -n +2 $SUM_FILE | awk '{print a,$1,$2,$3,$4,$5,$6,$7,$8}' a="$TRAIT" >> $ALL_SUM_FILE
    

done < $TRAIT_LIST