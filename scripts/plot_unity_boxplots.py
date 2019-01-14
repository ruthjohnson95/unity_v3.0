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
    parser.add_option("--unity", dest="unity_summary_file", default="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/sim_results_full/summary_unity_v3_10K_full.txt")
    parser.add_option("--outdir", dest="outdir", default="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/scripts")
    (options, args) = parser.parse_args()

    unity_summary_file = options.unity_summary_file
    outdir = options.outdir

    unity_df = pd.read_csv(unity_summary_file, sep=' ')
    #df = unity_df.dropna()
    df = unity_df

    p_list = [0.005, 0.01, 0.05]
    y_lim_a,y_lim_b = 0, .10
    ###############

    # EXPERIMENT: no-joint estimation, no-LD, N=100K, M=10K
    outfile="boxplot_joint_0_N_100K_M_10K_ld_0.pdf"

    # Set up the matplotlib figure
    fig, axes = plt.subplots(1, 3, figsize=(11,5),sharey='col')

    for i,p_true in enumerate(p_list):
        sns.boxplot(data=df.loc[(df['p'] == p_true) & (df['ld'] == 0) & (df['N'] == 100000)], x="sigG", y="p_est", ax=axes[i])
        axes[i].axhline(y=p_true, color='r', linestyle="--", linewidth=0.50)
        axes[i].set_xlabel("per-SNP variance (sigma_g)")

        if i == 0:
            axes[i].set_ylabel("Estimated prop of causals (p)")
        else:
            axes[i].yaxis.set_ticklabels([])
            axes[i].set_ylabel("")

        axes[i].set_title("Prop of causals (p=%.4g)" % p_true)
        axes[i].set_ylim(y_lim_a,y_lim_b)

    fig.suptitle('Joint Estimation: 0, LD: 0, N: 100K, M: 10K', fontsize=16)

    plot_fname = os.path.join(outdir, outfile)
    plt.savefig(plot_fname)
    plt.close()

    #############################

    # EXPERIMENT: no-joint estimation, no-LD, N=100K, M=10K
    outfile="boxplot_joint_0_N_100K_M_10K_ld_1.pdf"

    # Set up the matplotlib figure
    fig, axes = plt.subplots(1, 3, figsize=(11,5), sharey='col')

    for i,p_true in enumerate(p_list):
        sns.boxplot(data=df.loc[(df['p'] == p_true) & (df['ld'] == 1) & (df['N'] == 100000)], x="sigG", y="p_est", ax=axes[i])
        axes[i].axhline(y=p_true, color='r', linestyle="--", linewidth=0.50)
        axes[i].set_xlabel("per-SNP variance (sigma_g)")

        if i == 0:
            axes[i].set_ylabel("Estimated prop of causals (p)")
        else:
            axes[i].yaxis.set_ticklabels([])
            axes[i].set_ylabel("")

        axes[i].set_title("Prop of causals (p=%.4g)" % p_true)
        axes[i].set_ylim(y_lim_a,y_lim_b)

    fig.suptitle('Joint Estimation: 0, LD: 1, N: 100K, M: 10K', fontsize=16)

    plot_fname = os.path.join(outdir, outfile)
    plt.savefig(plot_fname)
    plt.close()

    #############################
    ###     N=1Mil            ###
    #############################

    # EXPERIMENT: no-joint estimation, no-LD, N=100K, M=10K
    outfile="boxplot_joint_0_N_1Mil_M_10K_ld_0.pdf"

    # Set up the matplotlib figure
    fig, axes = plt.subplots(1, 3, figsize=(11,5),sharey='col')

    for i,p_true in enumerate(p_list):
        sns.boxplot(data=df.loc[(df['p'] == p_true) & (df['ld'] == 0) & (df['N'] == 1000000)], x="sigG", y="p_est", ax=axes[i])
        axes[i].axhline(y=p_true, color='r', linestyle="--", linewidth=0.50)
        axes[i].set_xlabel("per-SNP variance (sigma_g)")

        if i == 0:
            axes[i].set_ylabel("Estimated prop of causals (p)")
        else:
            axes[i].yaxis.set_ticklabels([])
            axes[i].set_ylabel("")

        axes[i].set_title("Prop of causals (p=%.4g)" % p_true)
        axes[i].set_ylim(y_lim_a,y_lim_b)

    fig.suptitle('Joint Estimation: 0, LD: 0, N: 1Mil, M: 10K', fontsize=16)

    plot_fname = os.path.join(outdir, outfile)
    plt.savefig(plot_fname)
    plt.close()

    #############################

    # EXPERIMENT: no-joint estimation, no-LD, N=100K, M=10K
    outfile="boxplot_joint_0_N_1Mil_M_10K_ld_1.pdf"

    # Set up the matplotlib figure
    fig, axes = plt.subplots(1, 3, figsize=(11,5), sharey='col')

    for i,p_true in enumerate(p_list):
        sns.boxplot(data=df.loc[(df['p'] == p_true) & (df['ld'] == 1) & (df['N'] == 1000000)], x="sigG", y="p_est", ax=axes[i])
        axes[i].axhline(y=p_true, color='r', linestyle="--", linewidth=0.50)
        axes[i].set_xlabel("per-SNP variance (sigma_g)")

        if i == 0:
            axes[i].set_ylabel("Estimated prop of causals (p)")
        else:
            axes[i].yaxis.set_ticklabels([])
            axes[i].set_ylabel("")

        axes[i].set_title("Prop of causals (p=%.4g)" % p_true)
        axes[i].set_ylim(y_lim_a,y_lim_b)

    fig.suptitle('Joint Estimation: 0, LD: 1, N: 1Mil, M: 10K', fontsize=16)

    plot_fname = os.path.join(outdir, outfile)
    plt.savefig(plot_fname)
    plt.close()

    #############################
    ###     Joint Estimation  ###
    #############################

    unity_summary_file = "/u/home/r/ruthjohn/ruthjohn/unity_v3.0/sim_results_10K/summary_unity_v3_10K.txt"
    unity_df = pd.read_csv(unity_summary_file, sep=' ')
    df = unity_df

    y_lim_a,y_lim_b = 0, .50
    ##############################

    # EXPERIMENT: no-joint estimation, no-LD, N=100K, M=10K
    outfile="boxplot_joint_1_N_100K_M_10K_ld_1.pdf"

    # Set up the matplotlib figure
    fig, axes = plt.subplots(1, 3, figsize=(11,5), sharey='col')

    for i,p_true in enumerate(p_list):
        sns.boxplot(data=df.loc[(df['p'] == p_true) ], x="sigG", y="p_est", ax=axes[i])
        axes[i].axhline(y=p_true, color='r', linestyle="--", linewidth=0.50)
        axes[i].set_xlabel("per-SNP variance (sigma_g)")

        if i == 0:
            axes[i].set_ylabel("Estimated prop of causals (p)")
        else:
            axes[i].yaxis.set_ticklabels([])
            axes[i].set_ylabel("")

        axes[i].set_title("Prop of causals (p=%.4g)" % p_true)
        axes[i].set_ylim(y_lim_a,y_lim_b)

    fig.suptitle('Joint Estimation: 1, LD: 1, N: 100K, M: 10K', fontsize=16)

    plot_fname = os.path.join(outdir, outfile)
    plt.savefig(plot_fname)
    plt.close()


    #############################
    ###    Joint-Est no-LD    ###
    #############################

    unity_summary_file = "/u/home/r/ruthjohn/ruthjohn/unity_v3.0/sim_results_full_varyH/summary_unity_v3_10K_full.txt"
    unity_df = pd.read_csv(unity_summary_file, sep=' ')
    df = unity_df.dropna()

    y_lim_a,y_lim_b = 0, 1.0
    ##############################

    # EXPERIMENT: no-joint estimation, no-LD, N=100K, M=10K
    outfile="boxplot_joint_1_N_100K_M_10K_ld_0.pdf"

    # Set up the matplotlib figure
    fig, axes = plt.subplots(1, 3, figsize=(11,5), sharey='col')

    for i,p_true in enumerate(p_list):
        sns.boxplot(data=df.loc[(df['p'] == p_true) ], x="sigG", y="p_est", ax=axes[i])
        axes[i].axhline(y=p_true, color='r', linestyle="--", linewidth=0.50)
        axes[i].set_xlabel("per-SNP variance (sigma_g)")

        if i == 0:
            axes[i].set_ylabel("Estimated prop of causals (p)")
        else:
            axes[i].yaxis.set_ticklabels([])
            axes[i].set_ylabel("")

        axes[i].set_title("Prop of causals (p=%.4g)" % p_true)
        axes[i].set_ylim(y_lim_a,y_lim_b)

    fig.suptitle('Joint Estimation: 1, LD: 0, N: 100K, M: 10K', fontsize=16)

    plot_fname = os.path.join(outdir, outfile)
    plt.savefig(plot_fname)
    plt.close()

    ##############################

    # EXPERIMENT: no-joint estimation, no-LD, N=100K, M=10K
    y_lim_a,y_lim_b = 0, .0002
    outfile="boxplot_joint_1_N_100K_M_10K_ld_0_sigG.pdf"

    # Set up the matplotlib figure
    fig, axes = plt.subplots(1, 3, figsize=(11,5), sharey='col')

    sigG_list = [1e-5, 0.0001, 0.001]
    #p_list = [0.005, 0.01, 0.05]

    for i,sigG in enumerate(sigG_list):
        sns.boxplot(data=df.loc[(df['sigG'] == sigG) ], x="p", y="sigG_est", ax=axes[i])
        axes[i].axhline(y=sigG, color='r', linestyle="--", linewidth=0.50)
        axes[i].set_xlabel("per-SNP variance (sigma_g)")

        if i == 0:
            axes[i].set_ylabel("per-SNP variance (sigma_g)")
        else:
            axes[i].yaxis.set_ticklabels([])
            axes[i].set_ylabel("")

        axes[i].set_title("per-SNP variance: %.4g" % sigG)
        axes[i].set_ylim(y_lim_a,y_lim_b)

    fig.suptitle('Joint Estimation: 1, LD: 0, N: 100K, M: 10K', fontsize=16)

    plot_fname = os.path.join(outdir, outfile)
    plt.savefig(plot_fname)
    plt.close()

    """
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
    """

if __name__== "__main__":
  main()
