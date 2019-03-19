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
    parser.add_option("--unity", dest="unity_summary_file", default="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/sim_results_kk/summary_unity_v3_10K_kk.txt")
    parser.add_option("--outdir", dest="outdir", default="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/figs")
    (options, args) = parser.parse_args()

    unity_summary_file = options.unity_summary_file
    outdir = options.outdir

    df = pd.read_csv(unity_summary_file, sep=' ')
    df = df.dropna()

    y_lim_a,y_lim_b = 0, .025

    ###############
    p = 0.01
    maf = 0.0
    ld = 0.0
    r1 = 0.0
    r2=1.0

    outfile = "unity_kk_p_0.01.pdf"

    fig, axes = plt.subplots(1, 2, figsize=(9,5),sharey='col')

    sns.boxplot(data=df.loc[(df['p'] == p) & (df['maf'] == maf) & (df['ld'] == ld)  & (df['maf_low'] == r1) & (df['maf_high'] == r2)], x="h2", y="p_est", ax=axes[0], palette="Blues_d")
    axes[0].axhline(y=p, color='r', linestyle="--", linewidth=0.50)
    axes[0].set_xlabel("genome-wide heritabilty (h2)")
    axes[0].set_ylabel("Estimated prop of causals (p)")            
    axes[0].set_title("Prop of causals (p=%.4g)" % p)
    axes[0].set_title("P: %.4g, MAF: %.4g, LD: %.4g, Range: %.4g-%.4g" % (p, maf, ld, r1, r2))

    p = 0.01
    maf = 1.0
    ld = 0.75
    r1 = 0.05
    r2=0.50

    sns.boxplot(data=df.loc[(df['p'] == p) & (df['maf'] == maf) & (df['ld'] == ld)  & (df['maf_low'] == r1) & (df['maf_high'] == r2)], x="h2", y="p_est", ax=axes[1], palette="Blues_d")
    axes[1].axhline(y=p, color='r', linestyle="--", linewidth=0.50)
    axes[1].set_xlabel("genome-wide heritabilty (h2)")
    axes[1].set_ylabel("Estimated prop of causals (p)")
    axes[1].set_title("P: %.4g, MAF: %.4g, LD: %.4g, Range: %.4g-%.4g" % (p, maf, ld, r1, r2))

    plot_fname = os.path.join(outdir, outfile)
    plt.savefig(plot_fname)
    plt.close()


if __name__== "__main__":
  main()
