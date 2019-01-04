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
    parser.add_option("--unity", dest="unity_summary_file", default="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/scripts/summary_unity_v3_10K.txt")
    parser.add_option("--genesis", dest="genesis_summary_file", default="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/scripts/summary_genesis_10K.txt")
    parser.add_option("--outdir", dest="outdir", default="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/scripts")
    parser.add_option("--outfile", dest="outfile", default="boxplot_10K_p.pdf")
    (options, args) = parser.parse_args()

    unity_summary_file = options.unity_summary_file
    genesis_summary_file = options.genesis_summary_file
    outdir = options.outdir
    outfile = options.outfile

    unity_df = pd.read_csv(unity_summary_file, sep=' ')
    unity_df['model'] = 'unity'

    genesis_df = pd.read_csv(genesis_summary_file, sep=' ')
    genesis_df['model'] = 'genesis'

    df = pd.concat([unity_df, genesis_df])

    p_list = [0.005, 0.01, 0.05]

    # Set up the matplotlib figure
    fig, axes = plt.subplots(1, 3, figsize=(11,5),sharex='col')
    #sns.set_style("whitegrid")

    for i,p_true in enumerate(p_list):
        #sns.set_style("whitegrid")
        sns.boxplot(data=df.loc[df['p'] == p_true], x="sigG", y="p_est", hue="model", ax=axes[i])
        axes[i].axhline(y=p_true, color='r', linestyle="--", linewidth=0.50)
        axes[i].set_xlabel("per-SNP variance (sigma_g)")

        if i == 0:
            axes[i].set_ylabel("Estimated prop of causals")
        else:
            axes[i].yaxis.set_ticklabels([])
            axes[i].set_ylabel("")

        axes[i].set_title("Prop of causals (p=%.4g)" % p_true)

    plot_fname = os.path.join(outdir, outfile)
    plt.savefig(plot_fname)

    #### Plot SigmaG

    sigG_list = [0.00001, 0.00010, 0.00100]

    # Set up the matplotlib figure
    fig, axes = plt.subplots(1, 3, figsize=(11,5),sharex='col')
    #sns.set_style("whitegrid")

    for i,sigG_true in enumerate(sigG_list):
        #sns.set_style("whitegrid")
        sns.boxplot(data=df.loc[df['sigG'] == sigG_true], x="p", y="sigG_est", hue="model", ax=axes[i])
        axes[i].axhline(y=sigG_true, color='r', linestyle="--", linewidth=0.50)
        axes[i].set_xlabel("Prop of causals (p)")

        if i == 0:
            axes[i].set_ylabel("Estimated genetic variance (sigG)")
        else:
            axes[i].yaxis.set_ticklabels([])
            axes[i].set_ylabel("")

        axes[i].set_title("Per-snp genetic variance (sigG=%.4g)" % sigG_true)

    plot_fname = os.path.join(outdir, "boxplot_10K_sigG.pdf")
    plt.savefig(plot_fname)


if __name__== "__main__":
  main()
