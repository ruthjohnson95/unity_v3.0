import pandas as pd
import os
import scipy.stats as st
import numpy as np 

all_summary_file = "/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/SUMMARY/ALL.summary.txt"
trait_master_dir = "/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly"
outfile="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/SUMMARY/ALL.summary.gwas.txt"


df = pd.read_csv(all_summary_file, sep=' ')
df['GWAS_HITS'] = None

# lookup loci file 
for i, row in df.iterrows():
    trait = row['TRAIT']
    start = row['START']
    stop = row['STOP']
    chr = row['CHR']
    block = row['BLOCK']
    prefix = "chr_{}_start_{}_stop_{}.loci".format( chr, start, stop)
    loci_file = os.path.join(trait_master_dir, trait, block, prefix)

    loci_df = pd.read_csv(loci_file, sep=' ')

#    import pdb; pdb.set_trace()
#    (1-st.norm.cdf(0.01))*2
    pvalue = np.subtract(1, st.chi2.cdf(np.power(loci_df['Z'].values, 2), 1.0))
#    print min(pvalue)
    # find num gwas hits
    num_hits = len(np.where(pvalue <= 5e-8)[0])
    df.loc[i, 'GWAS_HITS'] = num_hits


# save file
df.to_csv(outfile, index=False)
