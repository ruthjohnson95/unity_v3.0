#!/usr/bin/env python

from optparse import OptionParser 
import numpy as np
import scipy.stats as st
import math 
import sys 
import os 
import logging 
import gzip 
import pandas as pd

# setup global logging 
logging.basicConfig(format='%(asctime)s - %(message)s', datefmt='%d-%b-%y %H:%M:%S', level=logging.INFO)

# global priors
beta_lam = 0.20 # prior for proportion p, p ~ Beta(beta_lam, beta_lam)

# global constants used to check for under/overflow
LOG_MIN = 1.7976931348623157e-308
LOG_MAX = 1.7976931348623157e+308
EXP_MAX = math.log(sys.float_info.max)
MAX = sys.float_info.max
MIN = sys.float_info.min

# simulates gwas effect sizes assuming an infintiesimal variance (h/M)
def simulate_ivar(p_sim, sigma_g_m, N, M, V):
    c = st.bernoulli.rvs(p=p_sim, size=M)
    true_p = (np.sum(c)/float(M))

    sd = math.sqrt(sigma_g_m)
    gamma = st.norm.rvs(loc=0, scale=sd, size=M)
    beta = np.multiply(gamma, c)
    h_sim = sigma_g_m * M 
    sigma_e = (1-h_sim)/float(N)

    mu = np.matmul(V, beta)
    env_cov = np.multiply(np.eye(M), sigma_e)
    cov = np.matmul(V, env_cov)
    z = st.multivariate_normal.rvs(mean=mu, cov=cov)

    return z, c, gamma, true_p


# simulates GWAS across entire genome
def simulate_ivar_gw(p_sim, h_sim, N, B, ld_dir, outdir, M=None):

	total_causals_gw = 0 
	M_gw = 0 
	ld_files = [] 

	ld_file_counter = 0

	# count how many SNPs if not provided 
	if M is None:
		for ld_file in os.listdir(ld_dir):
			if ld_file_counter < B:

	    		# process ld files 
				ld_file_b = os.path.join(ld_dir, ld_file)


				ld_b = np.loadtxt(ld_file_b)
				M_b = ld_b.shape[0]

				# add to running total of SNPs 
				M_gw += M_b 	

				# add ld filename to running list 
				ld_files.append(ld_file_b)		

				ld_file_counter += 1 

			else:
			 	# processed B ld files--exiting loop over files 
				break
	else: # user provided M 
		M_gw = M 


	# draw betas with LD 
	ld_file_counter = 0 
	for ld_file in os.listdir(ld_dir):

		if ld_file_counter < B:
			ld_file_b = os.path.join(ld_dir, ld_file)

			sigma_g_m = h_sim/float(M_gw)
			ld_b = np.loadtxt(ld_file_b)

			logging.info("Simulating effect sizes using ld matrix: %s" % os.path.basename(ld_file_b))
			
			M_b = ld_b.shape[0]
			z_b, c_b, gamma_b, true_p = simulate_ivar(p_sim, sigma_g_m, N, M_b, ld_b)

			# keep running total of total causals 
			total_causals_gw += np.sum(c_b)

			# save betas to file 
			locus_file_base = os.path.basename(ld_file_b)
			locus_prefix = locus_file_base.split('.')
			locus_fname = locus_prefix[0]+'.'+locus_prefix[1]+'.'+locus_prefix[2]+'.gwas'

			locus_full_fname = os.path.join(outdir, locus_fname)

			z_df = pd.DataFrame(data=z_b, columns=['BETA_STD'])		

			z_df.to_csv(locus_full_fname, sep=' ', index=False)

			logging.info("Saving locus to: %s" % locus_fname)

			ld_file_counter += 1 

		else:
			break 

        true_p = total_causals_gw/float(M_gw)
        logging.info("True prop causals: %.4f" % true_p)

	return


def print_header(sim_name, p_sim, h_sim, N, blocks, seed, outdir, ld_half_dir):
	print "- - - - - - - - - - UNITY v3.0 simulation - - - - - - - - -"

	print "Simulation Name: %s" % sim_name
	print "Prop causals: %.4f" % p_sim 
	print "Heritability: %.4f" % h_sim 
	print "Sample size: %d" % N 
	print "Num blocks: %d" % blocks
	print "Seed: %d" % seed
	print "Outputing simulated gwas to directory: %s" % outdir 

	if ld_half_dir is None:
		print "LD dir: None...simulating without LD"
	else:
		print "LD dir: %s" % ld_half_dir

	print "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

	return 


def main():
	parser = OptionParser() 
	parser.add_option("--sim_name", dest="sim_name", default="test_pipeline")
	parser.add_option("--h_sim", dest="h_sim", default=0.20)
	parser.add_option("--p_sim", dest="p_sim", default=0.05)
	parser.add_option("--N", dest="N", default=100000)
	parser.add_option("--blocks", dest="blocks", default=1)
	parser.add_option("--seed", dest="seed", default=100)
	parser.add_option("--outdir", dest="outdir")
	parser.add_option("--ld_dir", dest="ld_dir")
	parser.add_option("--ld_half_dir", dest="ld_half_dir")
	parser.add_option("--M", dest="M")

	(options, args) = parser.parse_args() 

	sim_name = options.sim_name 
	h_sim = float(options.h_sim)
	p_sim = float(options.p_sim)
	N = int(options.N)
	B = int(options.blocks)
	seed = int(options.seed)
	outdir = options.outdir
	ld_dir = options.ld_dir 
	ld_half_dir = options.ld_half_dir
	M = options.M 
	if M is not None:
		M = int(M)

	# set the seed 
	np.random.seed(seed)

	print_header(sim_name, p_sim, h_sim, N, B, seed, outdir, ld_dir)

	simulate_ivar_gw(p_sim, h_sim, N, B, ld_dir, outdir, M=M)

	logging.info("FINISHED simulating")
	logging.info("Simulations can be found at: %s" % outdir)

if __name__== "__main__":
  main()





