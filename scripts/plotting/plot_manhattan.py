#!/usr/bin/env python
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import os
import numpy as np 
import sys 

sns.set(color_codes=True)

trait=sys.argv[1]
print trait 
if trait is None:
    print "ERROR: need to specify trait"
    exit(1)

outdir="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/SUMMARY"

for block_size in ["6mb", "12mb", "24mb", "48mb"]:
    results_file = "/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/%s/%s.summary.txt" % (trait, trait)

    df = pd.read_csv(results_file, sep=' ')

    H2_cutoff=0
    M_cutoff=0

    # drop nans
    df_filter = df.dropna()
    df_filter = df_filter.loc[df['BLOCK'] == block_size]
    df_filter = df_filter.reset_index() 

    p_est = df_filter['P_EST']
    h2 = df_filter['H2']
    M = df_filter['M']

    chr_colors = []

    for index, row in df_filter.iterrows():
        if row['CHR'] % 2 == 0:
            chr_colors.append('black')
        else:
            chr_colors.append('blue')


    # get xticks for chr
    chr_ticks = []
    for chr in range(1,23):
        chr_tick = np.median(df_filter.loc[df_filter['CHR']==chr].index)
        chr_ticks.append(chr_tick)
        
    B = len(p_est)

    # remove SNPs with h2 <= 0 
    h2.loc[ h2 <= 0] = 0
    
    # remove where M*p < 1
    p_est.loc[ np.multiply(p_est, M) < 1] = 0

    # compute correlation between H2 and P
    corr = np.corrcoef(h2, p_est)[0,1]
    print "Correlation-%s: %.4g" % (block_size, corr)

    # average block size
    avg_M = np.mean(M)
    print "Avg M-%s: %.4g" % (block_size, avg_M)
    
    # average h^2
    avg_h2 = np.mean(h2)
    print "Avg h2-%s: %.4g" % (block_size, avg_h2)

    # average p
    avg_p = np.mean(p_est)
    print "Avg p-%s: %.4g" % (block_size, avg_p)

    # plot the per-SNP h2
    per_SNP_h2 = np.divide(h2, np.multiply(p_est, M))

    fig, ax = plt.subplots(4, sharex=True)

    ax[0].bar(range(0, B), p_est, width=1.0, color=chr_colors)
    ax[0].set_xlabel("Proportion of causals - %s" % block_size)
    ax[0].set_xlim([0, B-1])
    
    ax[1].bar(range(0, B), h2, width=1.0, color=chr_colors)
    ax[1].set_xlabel("Local h2g - %s" % block_size)
    ax[1].set_xlim([0, B-1])

    ax[2].bar(range(0, B), per_SNP_h2, width=1.0, color=chr_colors)
    ax[2].xaxis.set_ticks(chr_ticks)
    ax[2].xaxis.set_ticklabels(np.arange(22)+1, fontsize=6)
    ax[2].set_xlabel("Estimated per-SNP h2 - %s" % block_size)
    ax[2].set_xlim([0, B-1])

    # Number of causal SNPs
    M_c = np.multiply(p_est, M)
    ax[3].bar(range(0,B), M_c, width=1.0, color=chr_colors)
    ax[3].xaxis.set_ticks(chr_ticks)
    ax[3].xaxis.set_ticklabels(np.arange(22)+1, fontsize=6)
    ax[3].set_xlabel("Estimated number of causal SNPs - %s" % block_size)
    ax[3].set_xlim([0, B-1])

    fig.suptitle("%s: %s" % (trait, block_size))

    plt.savefig(os.path.join(outdir, "manhattan_%s_%s.pdf") % (trait, block_size))
    plt.close()
