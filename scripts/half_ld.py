#!/usr/bin/env python

from optparse import OptionParser 
import numpy as np
import scipy.stats as st
import math 
import sys 
import os 
import logging 
import pandas as pd

# set up global logging 
logging.basicConfig(format='%(asctime)s - %(message)s', datefmt='%d-%b-%y %H:%M:%S', level=logging.INFO)


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


def main(): 
    parser = OptionParser() 
    parser.add_option("--ld_half_dir", dest="ld_half_dir")
    parser.add_option("--ld_dir", dest="ld_dir")
    parser.add_option("--blocks", dest="blocks")
    parser.add_option("--ld_file", dest="ld_file")
    parser.add_option("--ld_out", dest="ld_out")

    (options, args) = parser.parse_args() 
    ld_half_dir = options.ld_half_dir 
    ld_dir = options.ld_dir 
    ld_file = options.ld_file 
    ld_out = options.ld_out 

    B = options.blocks
    if B is not None:
        B = int(B) 

    ld_file_counter = 0 

    if ld_file is not None:
        # only process 1 file at a time 
        ld_file_b = ld_file 

        ld_b = np.loadtxt(ld_file_b)

        logging.info("Taking 1/2 power of ld matrix: %s" % os.path.basename(ld_file_b))

        ld_half_b = truncate_matrix_half(ld_b)

        ld_file_base = os.path.basename(ld_file_b)
        ld_string = ld_file_base.split('.')
        ld_prefix = ld_string[0] + '.'+ ld_string[1] + '.' + ld_string[2] + '.half_ld'
        if ld_out is not None: # use user specified outfname
            ld_half_fname = ld_out 
        else:
            ld_half_fname = os.path.join(ld_half_dir, ld_prefix)

        np.savetxt(ld_half_fname ,ld_half_b)

        logging.info("Transformed ld matricies can be found in: %s" % ld_half_dir)
    elif ld_dir is not None:
        for ld_file in os.listdir(ld_dir):
        
            if ld_file_counter < B:
                ld_file_b = os.path.join(ld_dir, ld_file)

                ld_b = np.loadtxt(ld_file_b)

                logging.info("Taking 1/2 power of ld matrix: %s" % os.path.basename(ld_file_b))

                ld_half_b = truncate_matrix_half(ld_b) 

                ld_file_base = os.path.basename(ld_file_b)
                ld_string = ld_file_base.split('.') 
                ld_prefix = ld_string[0] + '.'+ ld_string[1] + '.' + ld_string[2] + '.half_ld'
                ld_half_fname = os.path.join(ld_half_dir, ld_prefix)

                np.savetxt(ld_half_fname ,ld_half_b)
                
                logging.info("Saving 1/2 power ld matrix to: %s" % os.path.basename(ld_half_fname))
                
                ld_file_counter += 1 

            else:
                break 


            logging.info("FINISHED transforming ld matrices to 1/2 power")
            logging.info("Transformed ld matricies can be found in: %s" % ld_half_dir)
    else:
        # user did not give correct input 
        logging.info("ERROR: need to provide ld dir or ld file...exiting")
        exit(1) 


if __name__== "__main__":
  main()
    



