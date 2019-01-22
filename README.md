# Running Simulations (Kathy)

```
unity_sims
	|__misc
		|__(LD files)
	|
	|__scripts
	|__sims
	|	|__data
	|	|__results
	|
	|__src

```

### 1. Define simulation paraters in `prefix_h2.txt` (or `prefix_h2_noLD.txt`)

Each column corresponds to: `p, h2, N, LD`

```
$ head prefix_h2.txt
0.005	0.1	 10000	1
0.01	0.1 10000	1
0.05	0.1 10000	1
```

### 2. Simulate data

...

### 3. Run inference

(`run_inference_h2.sh`)

The header of the script defines the flags used by hoffman. Each prefix file has 27 simulation settings with 100 simulations for each setting, thus a total of 2700 jobs. One might be able to lower the amount of requested memory-- especially with no-LD. 

```
#!/usr/bin/env sh
#$ -cwd
#$ -j y
#$ -l h_data=10G,h_rt=6:00:00,highp
#$ -o run_inference_h2.log
#$ -t 1-2700:1
```

The only path a user must change is `MASTER_PATH`. This path is then used throughout the script, eliminating hard-coded paths. Thus, make sure the scipts follow the listed directory layout as listed above. 

```
#SGE_TASK_ID=1

MASTER_PATH=/u/home/r/ruthjohn/gleb_kathy_ruthie/unity_sims
SCRIPT_DIR=${MASTER_PATH}/scripts
SRC_DIR=${MASTER_PATH}/src
SIM_DIR=${MASTER_PATH}/sims/data
SIM_RESULTS_DIR=${MASTER_PATH}/sims/results

```

Here we define the prefix file. This file has no header, space-delimited, with on simulation setting on each line that follows: `p, h2, N, LD` as listed above. Next, the LD files and half-power LD files are listed. If half-LD must be computed, one can use `scripts/half_ld.py`. Either `.npy` or `.txt` files are okay. 

```
PREFIX_PATH=${MASTER_PATH}/misc/prefix_h2_noLD.txt
UKBB_LD=${MASTER_PATH}/misc/chr22.0.0.ld.npy
UKBB_HALF=${MASTER_PATH}/misc/chr22.0.0.half_ld.npy
NO_LD=${MASTER_PATH}/misc/chr22.0.0.identity
```

Based off of the parameters listed in `prefix.txt`, the specified GWAS and LD file will be used. Then the GWAS effect sizes must be transformed by left-multiplying by V^-1/2. This is performed using the `transform_betas.py` script; the transformed effect sizes are saved in the original GWAS file under the header `BETA_STD_I`.

```
# transform betas
python ${SCRIPT_DIR}/transform_betas.py --gwas_file $GWAS_FILE --ld_file $LD_FILE
```
The main inference routine is called by `main_new.py`. We use 250 MCMC iterations-- this does not need to vary across simulations. Most flags are straightforward, but these are important to note:

`--id` file header that will be used for the output file

`--H_gw` genome-wide heritability

`--M_gw` number of SNPs genome-wide (NOTE: this is not 
neccesarily how many SNPs are in the simulated GWAS)

`--dp` speedup flag


```
ITS=250
python ${SRC_DIR}/main_new.py \
	--seed $i \
	--N $N \
	--id $PREFIX \
	--its $ITS \
	--ld_half_file $LD_HALF_FILE \
	--gwas_file $GWAS_FILE  \
	--outdir $SIM_RESULTS_DIR \
	--H_gw $H2 \
	--M_gw $M_GW \
	--dp
```

Finally, to run all jobs:

```
qsub scripts/run_inference_h2.sh
```

### 4. Summarize results

```
bash scripts/summarize_unity.sh
```

### 5. Plot boxplots
...
