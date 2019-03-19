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

trait_list = ["height", "diabetes_any", "ra_self_rep"]
color_list = ["red", "black", "blue"]

outdir="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/SUMMARY"

for i, trait in enumerate(trait_list):

    block_size = "6mb"
    results_file = "/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/%s/%s.summary.txt" % (trait, trait)

    df = pd.read_csv(results_file, sep=' ')

    H2_cutoff=0
    M_cutoff=0

    # drop nans
    df_filter = df.dropna()
    df_filter = df_filter.loc[df['BLOCK'] == block_size]
    df_filter = df_filter.loc[df_filter['H2'] >= H2_cutoff ]
    df_filter = df_filter.loc[df['H2'] >= H2_cutoff ]
    df_filter = df_filter.reset_index() 

#    df_filter = df_filter.loc[(df['M'] >= M_cutoff) & (df['H2'] >= H2_cutoff) ]
    p_est = df_filter['P_EST']
    h2 = df_filter['H2']
    M = df_filter['M']

    chr_colors = []

    for index, row in df_filter.iterrows():
        if row['CHR'] % 2 == 0:
            chr_colors.append('black')
        else:
            chr_colors.append('blue')
        
    B = len(p_est)

    # plot the per-SNP h2
    per_SNP_h2 = np.divide(h2, np.multiply(p_est, M))

    fig, ax = plt.subplots(1, sharex=True)
    
    ax.bar(range(0, B), per_SNP_h2, width=1.0, color=color_list[i])
    ax.set_title("Proportion of causals - %s" % block_size)
    ax.set_xlim([0, B-1])
    
fig.suptitle("%s: %s" % (trait, block_size))

plt.savefig(os.path.join(outdir, "manhattan_%s_%s_%s.pdf") % (trait_list[0], trait_list[1], trait_list[2]))
plt.close()
