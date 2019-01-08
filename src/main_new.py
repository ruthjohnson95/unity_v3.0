from mcmc import gibbs_sampler
from auxilary import print_header
import logging
from optparse import OptionParser
import numpy as np

def main():

    logging.basicConfig(format='%(asctime)s - %(message)s', datefmt='%d-%b-%y %H:%M:%S', level=logging.INFO)

    parser = OptionParser()
    parser.add_option("--s", "--seed", default="2019")
    parser.add_option("--H_snp", type=float)
    parser.add_option("--N", type=int)
    parser.add_option("--id", default="unique_id")
    parser.add_option("--its", type=int, default=250)
    parser.add_option("--ld_half_file")
    parser.add_option("--gwas_file")
    parser.add_option("--outdir")
    parser.add_option('--dp', action='store_true')
    parser.add_option("--profile", action='store_true')

    (options, args) = parser.parse_args()

    # set seed
    np.random.seed(options.seed)

    H_snp = options.H_snp
    N = options.N
    id = options.id
    its = options.its
    ld_half_file = options.ld_half_file
    gwas_file = options.gwas_file
    outdir = options.outdir
    dp_flag = options.dp
    profile_flag = options.profile

    # TODO: print header

    p_est, p_var, sigma_g_est, sigma_g_var, sigma_e_est, sigma_e_var, avg_log_like, var_log_like \
        = gibbs_sampler(...)

    # TODO: print results

if __name__== "__main__":
  main()
