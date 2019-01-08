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
    parser.add_option("--unity", dest="unity_summary_file", default="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/scripts/summary_unity_v3_10K_full.txt")
    parser.add_option("--outdir", dest="outdir", default="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/scripts")
    parser.add_option("--outfile", dest="outfile", default="boxplot_10K_full_p.pdf")
    (options, args) = parser.parse_args()

    unity_summary_file = options.unity_summary_file
    outdir = options.outdir
    outfile = options.outfile

    unity_df = pd.read_csv(unity_summary_file, sep=' ')
    df = unity_df.dropna()

    p_list = [0.005, 0.01, 0.05]

    # Set up the matplotlib figure
    fig, axes = plt.subplots(2, 3, figsize=(11,5),sharex='col')
    #sns.set_style("whitegrid")

    for i,p_true in enumerate(p_list):
        # NO LD
        sns.boxplot(data=df.loc[(df['p'] == p_true) & (df['ld'] == 0) & (df['N'] == 100000)], x="sigG", y="p_est", ax=axes[0,i])
        axes[0,i].axhline(y=p_true, color='r', linestyle="--", linewidth=0.50)
        axes[0,i].set_xlabel("per-SNP variance (sigma_g)")

        if i == 0:
            axes[0,i].set_ylabel("Estimated prop of causals (No-LD)")
        else:
            axes[0,i].yaxis.set_ticklabels([])
            axes[0,i].set_ylabel("")

        axes[0,i].set_title("Prop of causals (p=%.4g)" % p_true)

    for i,p_true in enumerate(p_list):
        # YES LD
        sns.boxplot(data=df.loc[(df['p'] == p_true) & (df['ld'] == 1) & (df['N'] == 100000)], x="sigG", y="p_est", ax=axes[1,i])
        axes[1,i].axhline(y=p_true, color='r', linestyle="--", linewidth=0.50)
        axes[1,i].set_xlabel("per-SNP variance (sigma_g)")

        if i == 0:
            axes[1,i].set_ylabel("Estimated prop of causals (w/ LD)")
        else:
            axes[1,i].yaxis.set_ticklabels([])
            axes[1,i].set_ylabel("")

        axes[1,i].set_title("Prop of causals (p=%.4g)" % p_true)

    outfile="boxplot_M_10K_N_100K_full_p.pdf"
    plot_fname = os.path.join(outdir, outfile)
    plt.savefig(plot_fname)
    plt.close()

    #############################

    # Set up the matplotlib figure
    fig, axes = plt.subplots(2, 3, figsize=(11,5),sharex='col')
    #sns.set_style("whitegrid")

    for i,p_true in enumerate(p_list):
        # NO LD
        sns.boxplot(data=df.loc[(df['p'] == p_true) & (df['ld'] == 0) & (df['N'] == 1000000)], x="sigG", y="p_est", ax=axes[0,i])
        axes[0,i].axhline(y=p_true, color='r', linestyle="--", linewidth=0.50)
        axes[0,i].set_xlabel("per-SNP variance (sigma_g)")

        if i == 0:
            axes[0,i].set_ylabel("Estimated prop of causals (No-LD)")
        else:
            axes[0,i].yaxis.set_ticklabels([])
            axes[0,i].set_ylabel("")

        axes[0,i].set_title("Prop of causals (p=%.4g)" % p_true)

    for i,p_true in enumerate(p_list):
        # YES LD
        sns.boxplot(data=df.loc[(df['p'] == p_true) & (df['ld'] == 1) & (df['N'] == 1000000)], x="sigG", y="p_est", ax=axes[1,i])
        axes[1,i].axhline(y=p_true, color='r', linestyle="--", linewidth=0.50)
        axes[1,i].set_xlabel("per-SNP variance (sigma_g)")

        if i == 0:
            axes[1,i].set_ylabel("Estimated prop of causals (w/ LD)")
        else:
            axes[1,i].yaxis.set_ticklabels([])
            axes[1,i].set_ylabel("")

        axes[1,i].set_title("Prop of causals (p=%.4g)" % p_true)

    outfile="boxplot_M_10K_N_100Mil_full_p.pdf"
    plot_fname = os.path.join(outdir, outfile)
    plt.savefig(plot_fname)


if __name__== "__main__":
  main()
