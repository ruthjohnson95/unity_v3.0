#!/usr/bin/env python
import matplotlib
matplotlib.use('Agg')
from optparse import OptionParser
import seaborn as sns
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

def main():

    parser = OptionParser()
    parser.add_option("--unity", dest="unity_summary_file", default="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/sim_results_10K_h2/summary_unity_v3_10K_full.txt")
    parser.add_option("--genesis", dest="genesis_summary_file", default="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/sim_results_10K_h2/summary_genesis_10K.txt")
    parser.add_option("--outdir", dest="outdir", default="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/scripts")
    (options, args) = parser.parse_args()

    unity_summary_file = options.unity_summary_file
    genesis_summary_file = options.genesis_summary_file
    outdir = options.outdir

    unity_df = pd.read_csv(unity_summary_file, sep=' ')
    genesis_df = pd.read_csv(genesis_summary_file, sep=' ')

    unity_df['model'] = 'unity'
    genesis_df['model'] = 'genesis'
    df = pd.concat([unity_df, genesis_df])

    p_list = [0.005, 0.01, 0.05]
    N_list = [10000, 100000, 1000000]
    y_lim_a,y_lim_b = 0, .10
    ld_flag = 1
    ###############

    for N in N_list:
        # EXPERIMENT: joint estimation, LD, N=10K, M=10K
        outfile="unity_genesis_h2_N_%d_M_10K_ld_%d.pdf" % (N, ld_flag)

        # Set up the matplotlib figure
        fig, axes = plt.subplots(1, 3, figsize=(11,5),sharey='col')

        for i,p_true in enumerate(p_list):
            sns.boxplot(data=df.loc[(df['p'] == p_true) & (df['ld'] == ld_flag) & (df['N'] == N)], x="h2", y="p_est", hue="model", ax=axes[i])
            axes[i].axhline(y=p_true, color='r', linestyle="--", linewidth=0.50)
            axes[i].set_xlabel("genome-wide heritabilty (h2)")

            if i == 0:
                axes[i].set_ylabel("Estimated prop of causals (p)")
            else:
                axes[i].yaxis.set_ticklabels([])
                axes[i].set_ylabel("")

            axes[i].set_title("Prop of causals (p=%.4g)" % p_true)
            axes[i].set_ylim(y_lim_a,y_lim_b)

        fig.suptitle('Joint Estimation: 1, LD: %d, N: %d, M: 10K' % (ld_flag, N), fontsize=16)

        plot_fname = os.path.join(outdir, outfile)
        plt.savefig(plot_fname)
        plt.close()


if __name__== "__main__":
  main()
