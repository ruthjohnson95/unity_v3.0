"""
main.py

Main function that reads in inputs and calls main routine.
"""

from helper import print_header, print_func
from mcmc import gibbs_sampler_Hgw

import logging
import math
from optparse import OptionParser
import numpy as np
import pandas as pd
import os


def main():
    """Estimates the proportion of causals from GWAS summary statistics

    Given summary statistics (effect sizes) from GWAS and an estimate of
    genome-wide heritability (H_gw), MCMC is used to estimate the proportion
    of causal variants. An efficient implementation of the algorithm allows
    for runtime of O(M*K), where M=#SNPs and K=#causalSNPs

    Args:
        H_gw: estimated genome-wide heritability
        M_gw: number of SNPs genome-wide
        N: sample size of study
        ld_half_file: pre-computed 1/2 power of LD matrix; txt or .npy file
        gwas_file: transformed GWAS effect sizes created by left-multplying
            effects by V^-1/2; effects must be under header 'BETA_STD_I';
            txt file
        outdir: path to directory for results files
        seed: seed for random initialization
        id: string name for experiment
        its: number of MCMC iterations
        dp: boolean flag; use efficient update if flag present
        profile: boolean flag; profile code if flag present

    Returns:
        An output file containing posterior mean and posterior variance of
        the estimate of the proportion of causal variants, as well as the
        average likelihood and variance of the likelihood.

        example output file:
            Estimate p: 0.0020
            SD p: 0.0004606
            Avg log like: 1452.92
            Var log like: 2.12
    """

    logging.basicConfig(format='%(asctime)s - %(message)s', datefmt='%d-%b-%y %H:%M:%S', level=logging.INFO)

    parser = OptionParser()
    parser.add_option("--H_gw", type=float)
    parser.add_option("--M_gw", type=int)
    parser.add_option("--N", type=int)
    parser.add_option("--ld_half_file")
    parser.add_option("--gwas_file")
    parser.add_option("--outdir")
    parser.add_option("--seed", type=int, default="2019")
    parser.add_option("--id")
    parser.add_option("--its", type=int)
    parser.add_option("--dp", action="store_true", default=True)
    parser.add_option("--profile", action="store_true")

    (options, args) = parser.parse_args()

    # set seed
    seed = options.seed
    np.random.seed(seed)

    H_gw = options.H_gw
    M_gw = options.M_gw
    N = options.N
    id = options.id
    its = options.its
    ld_half_file = options.ld_half_file
    gwas_file = options.gwas_file
    outdir = options.outdir
    dp_flag = options.dp
    profile_flag = options.profile

    # open output filehandler
    outfile = os.path.join(outdir, id +'.' + str(seed) + ".unity_v3.log")
    f = open(outfile, 'w')

    print_header(id, H_gw, N, its, seed, gwas_file, ld_half_file, outdir, f)

    try: # txt file
        V_half = np.loadtxt(ld_half_file)
    except: # npy file
        V_half = np.load(ld_half_file)

    gwas = pd.read_table(gwas_file, sep=' ')
    z = np.asarray(gwas['BETA_STD_I'])

    p_est, p_var, avg_log_like, var_log_like, accept_percent = gibbs_sampler_Hgw(z, H_gw, M_gw, N, V_half, its, f,
                                                                 dp_flag, profile_flag)
    accept_percent = accept_percent*100
    print_func("Accept percent: %.4f" % accept_percent, f)
    print_func("Estimate p: %.4f" % p_est, f)
    print_func("SD p: %.4g" % math.sqrt(p_var), f)
    print_func("Avg log like: %.6g" % avg_log_like, f)
    print_func("Var log like: %.4g" % math.sqrt(var_log_like), f)
    f.close()


if __name__== "__main__":
  main()
