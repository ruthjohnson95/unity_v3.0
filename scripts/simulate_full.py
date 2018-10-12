#!/usr/bin/env python

from optparse import OptionParser
import numpy as np
import scipy.stats as st
import math
import sys
import os
import logging
import pandas as pd
import re


SEED = 0

# setup global logging
logging.basicConfig(format='%(asctime)s - %(message)s', datefmt='%d-%b-%y %H:%M:%S', level=logging.INFO)

def truncate_matrix_half(V):
    # make V pos-semi-def
    d, Q = np.linalg.eigh(V, UPLO='U')

    # reorder eigenvectors from inc to dec
    idx = d.argsort()[::-1]
    Q[:] = Q[:, idx]
    #d[:] = d.argsort()[::-1]

    # truncate small eigenvalues for stability
    d_trun = truncate_eigenvalues(d)

    d_trun_half = np.sqrt(d_trun)

    # mult decomp back together to get final V_trunc
    M1 = np.matmul(Q, np.diag(d_trun_half))
    V_trun_half = np.matmul(M1, np.matrix.transpose(Q))

    return V_trun_half

def truncate_eigenvalues(d):
    M = len(d)

    # order evaules in descending order
    d[::-1].sort()

    #running_sum = 0
    d_trun = np.zeros(M)

    # keep only positive evalues
    for i in range(0,M):
        if d[i] > 0:
            # keep evalue
            d_trun[i] = d[i]

    return d_trun


def truncate_matrix_neg_half(V):
    # make V pos-semi-def
    d, Q = np.linalg.eigh(V, UPLO='U')

    # reorder eigenvectors from inc to dec
    idx = d.argsort()[::-1]
    Q[:] = Q[:, idx]

    # truncate small eigenvalues for stability
    d_trun = truncate_eigenvalues(d)

    # square root of eigenvalues
    d_trun_half = np.sqrt(d_trun)

    # recipricol eigenvalues to do inverse
    d_trun_half_neg = np.divide(1, d_trun_half, where=d_trun_half!=0)


    # mult decomp back together to get final V_trunc
    M1 = np.matmul(Q, np.diag(d_trun_half_neg))
    V_trun_half_neg = np.matmul(M1, np.matrix.transpose(Q))

    return V_trun_half_neg


# simulate GWAS only for 1 block
def simulate_full_block_LD(p_sim, sigma_g, sigma_e, ld_file, outdir):

    V = np.loadtxt(ld_file)
    M = V.shape[0]

    logging.info("Simulating effect sizes using ld matrix: %s" % os.path.basename(ld_file))

    c = st.bernoulli.rvs(p=p_sim, size=M)
    true_p = (np.sum(c)/float(M))
    sd = math.sqrt(sigma_g)
    gamma = st.norm.rvs(loc=0, scale=sd, size=M)
    beta = np.multiply(gamma, c)
    mu = np.matmul(V, beta)
    env_cov = np.multiply(np.eye(M), sigma_e)
    cov = np.matmul(V, env_cov)
    z = st.multivariate_normal.rvs(mean=mu, cov=cov)

    df = pd.DataFrame(data=z, columns=['BETA_STD'])

    locus_fname = 'chr'+str(SEED)+'.0.0'+'.gwas'

    locus_full_fname = os.path.join(outdir, locus_fname)

    df.to_csv(locus_full_fname, sep=' ', index=False)

    true_p = np.sum(c)/float(M)

    logging.info("True prop causals: %.4f" % true_p)

    logging.info("Saving locus to: %s" % locus_fname)

    # calculate log like
    V_half = truncate_matrix_half(V)
    V_neg_half = truncate_matrix_neg_half(V)
    print V_neg_half

    z_tilde = np.matmul(V_neg_half, z)
    mu = np.matmul(V_half, np.multiply(gamma, c))
    cov = np.eye(M)*sigma_e
    log_like = st.multivariate_normal.logpdf(z_tilde, mu, cov)

    logging.info("True likelihood: %.6g" % log_like)

    return


def log_like(z, gamma, c, sigma_e, V_half):
    M = len(z)
    mu = np.matmul(V_half, np.multiply(gamma, c))
    cov = np.eye(M)*sigma_e
    log_like = st.multivariate_normal.logpdf(z, mu, cov)

    return log_like


def main():
    parser = OptionParser()
    parser.add_option("--sim_name", dest="sim_name", default="test_pipeline")
    parser.add_option("--sigma_g", dest="sigma_g", default=0.20)
    parser.add_option("--sigma_e", dest="sigma_e")
    parser.add_option("--p_sim", dest="p_sim", default=0.05)
    parser.add_option("--outdir", dest="outdir")
    parser.add_option("--seed", dest="seed", default=100)
    parser.add_option("--ld_file", dest="ld_file")

    (options, args) = parser.parse_args()
    print options

    sim_name = options.sim_name
    sigma_g = float(options.sigma_g)
    sigma_e = float(options.sigma_e)
    p_sim = float(options.p_sim)
    outdir = options.outdir
    ld_file = options.ld_file
    seed = int(options.seed)

    # set the seed
    global SEED
    SEED = seed
    np.random.seed(SEED)

    simulate_full_block_LD(p_sim, sigma_g, sigma_e, ld_file, outdir)

    logging.info("FINISHED simulating")
    logging.info("Simulations can be found at: %s" % outdir)


if __name__== "__main__":
  main()
