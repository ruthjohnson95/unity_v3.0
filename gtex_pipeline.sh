#!/usr/bin/env bash

#$ -cwd
#$ -j y
#$ -l h_data=10G,h_rt=6:00:00,highp
#$ -o tex_unity.log
#$ -t 1-85:1

# number of tasks for number of genes 

SGE_TASK_ID=1

source /u/local/Modules/default/init/modules.sh
module load python/2.7
module load R 

gtex_yaml=$1

if [ -z "$gtex_yaml" ]
then
    sim_yaml="gtex.yaml"
fi 

# parse yaml file 
TISSUE=$(cat $gtex_yaml | grep "TISSUE" | cut -d':' -f2 | tr -d " \t\n\r" )
N=$(cat $gtex_yaml | grep "SAMPLE SIZE" | cut -d':' -f2 | tr -d " \t\n\r" )
GTEX_DIR=$(cat $gtex_yaml | grep "GTEX DIR" | cut -d':' -f2 | tr -d " \t\n\r" )
PLINK=$(cat $gtex_yaml | grep "PLINK" | cut -d':' -f2 | tr -d " \t\n\r" )
REF_PANEL=$(cat $gtex_yaml | grep "REF PANEL" | cut -d':' -f2 | tr -d " \t\n\r" )
OUTDIR=$(cat $gtex_yaml | grep "OUTDIR" | cut -d':' -f2 | tr -d " \t\n\r" )
GENE_LIST=$(cat $gtex_yaml | grep "GENE LIST" | cut -d':' -f2 | tr -d " \t\n\r" )
SEED=$(cat $gtex_yaml | grep "SEED" | cut -d':' -f2 | tr -d " \t\n\r" )

# make simulation output dir 
SIMDIR=$OUT_DIR'/'$SIM_NAME
mkdir -p $SIMDIR

# make header 
echo "- - - - - - - - - - UNITY v3.0 Gtex Analysis - - - - - - - - -"
echo "TISSUE: "$TISSUE
echo "GENE LIST: "$GENE_LIST
echo "N: "$N

echo "Outputing results to directory: "$OUTDIR

echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"


    for line in `cat $GENE_LIST`
    do
	COUNTER=$((COUNTER+1))

	if [[ $COUNTER -eq $SGE_TASK_ID ]]
	then 

	DATE=`date '+%Y-%m-%d %H:%M:%S'`
	GENE=$(basename $line)
	echo $DATE" Analyzing gene: "$GENE

	GENE_FILE=${GTEX_DIR}/"GTEx."${TISSUE}/${GENE}
	GENE_PREFIX=${GENE%.*.*}

	# make locus file 
	Rscript wgt_to_gwas.R --wgt_file $GENE_FILE --N $N --outdir $OUTDIR 
	LOCUS=${OUTDIR}/${GENE_PREFIX}'.locus'

	# make SNP list 
	SNP_LIST=${OUTDIR}/${GENE_PREFIX}'.snplist'
	tail -n +2 $LOCUS | awk '{print $1}' > $SNP_LIST

	# get maf from 1000G 
	MAF_FILE=${OUTDIR}/${GENE_PREFIX}'.frq'
	CHR=$(tail -n +2 $LOCUS | head -n 1 | cut -d' ' -f2 )
	$PLINK --allow-no-sex --bfile $REF_PANEL.$CHR --freq --chr $CHR --extract $SNP_LIST --out ${OUTDIR}/${GENE_PREFIX}

	# add maf to locus and filter by maf 
	MAF_THRESH=0.05 
	Rscript scripts/add_maf_and_filter.R --locus_file $LOCUS_FILE --maf_file $MAF_FILE --maf_thresh $MAF_THRESH 

	# remake snplist after filtering
	tail -n +2 $LOCUS | awk '{print $1}' > $SNP_LIST

	# get LD 
	bash scripts/compute_LD.sh $SNP_LIST $PLINK $REF_PANEL $OUTDIR $MAF_THRESH 
	LD_FILE=${OUTDIR}/${GENE_PREFIX}.ld 
	
	# transform betas 
	python scripts/transform_betas.py --gwas_file $LOCUS_FILE --ld_file $LD_FILE 

	# convert to LD 1/2 
	python scripts/half_ld.py --ld_file $LD_FILE --ld_half_dir $OUTDIR 
	LD_HALF_FILE=${OUTDIR}/${${GENE_PREFIX}.half_ld 

        # run inference 
	ITS=1000
	python src/unity_v3_block.py --seed $SEED --H_gwas $H_GWAS  --id $GENE_PREFIX --ld_half_file $LD_HALF_FILE --gwas_file $LOCUS_FILE --outdir $OUTDIR --its $ITS 

fi # end SGE if-statement 

done # end loop through genes 
