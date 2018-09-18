from unity_metropolis import *
from auxilary import *
from unity_gibbs import *


"""
main.py

Main function for running sampler.

Command-line arguments:
    --s, --seed: seed number (default '7')
    --H: heritability
    --H_sim: simulation heritability
    --M: number of SNPs (default: 500)
    --N: sample size (default: 1000)
    --P: proportion of causal SNPs
    --id: output file name prefix
    --ITS: number of iterations for sampler (default: 500)
    --ld_flag: flag if modeling with LD (default: 'y')
    --ld_const: constant along diagonal of simulated LD matrix (default: .20)
    --plot: y/n to plotting trace plot, histogram, and density trace plot (default: 'n')
    --fix_initial: y/n fix starting point to simulated true values; 'y' means fixed start (default: 'n')
    --ivar: simulate with "infinitesimal" variance, sigma_g = h/M (default: 'y')
    --ld_file: user provided file with ld, no header
    --sumstats_file: user provided gwas summary statistics
    --profile: (y/n) profile code and output results to console

"""


def main():
    # get input options
    parser = OptionParser()
    parser.add_option("--s", "--seed", dest="seed", default="7")
    parser.add_option("--H_sim", "--H_sim", dest="H_sim")
    parser.add_option("--H", "--H", dest="H")
    parser.add_option("--M", "--M", dest="M", default=500)
    parser.add_option("--N", "--N", dest="N", default=1000)
    parser.add_option("--P", "--P", dest="P", default=None)
    parser.add_option("--id", "--id", dest="id", default="unique_id")
    parser.add_option("--ITS", "--ITS", dest="ITS", default=500)
    parser.add_option("--ld_flag", "--ld_flag", dest="ld_flag", default='y')
    parser.add_option("--ld_const", "--ld_const", dest="ld_const", default=0.20)
    parser.add_option("--plot", "--plot", dest="plot", default='n')
    parser.add_option("--fix_initial", "--fix_initial", dest="fix_initial", default='n') # yes for fixed start
    parser.add_option("--ivar", "--ivar", dest="ivar", default='y')
    parser.add_option("--ld_file", "--ld_file", dest="ld_file")
    parser.add_option("--sumstats_file", "--sumstats_file", dest="sumstats_file")
    parser.add_option("--profile", "--profile", dest="profile", default='n')
    (options, args) = parser.parse_args()

    # set seed
    seed = int(options.seed)
    random.seed(seed)
    np.random.seed(seed)

    # get simulation params
    M = int(options.M)
    N = int(options.N)
    ITS = int(options.ITS)

    # profile option
    profile = options.profile

    # check if user provided value for H
    H = options.H  # true H
    if H is not None:
        h_true = float(H)
    else:
        h_true = None

    # sumstats file
    sumstats_file = options.sumstats_file

    if sumstats_file is None: # simulate
        p_sim = float(options.P)
        h_sim = float(options.H_sim)
        fix_initial = options.fix_initial
    else:
        p_sim = None
        h_sim = None
        fix_initial = 'n'

    ld_flag = options.ld_flag
    if ld_flag == 'n':
        ld_const = "0"
    else:
        ld_const = options.ld_const

    ld_file = options.ld_file
    if ld_file is not None:
        ld_const = 'f'

    # file I/O for results
    ID = options.id
    f = open("out.%s.ld_%s.%d" % (ID, ld_const, seed), 'w')
    plot = options.plot

    # infinitesimal variance
    ivar = options.ivar

    # simulate LD matrix
    if ld_flag == 'y' and ld_file is not None:
        V = np.loadtxt(ld_file) # use LD provided by user
        ld_const = None
        #print(V)
        if len(V) != M:
            print "Sample size doesn't correspond with LD file...exiting"
            exit(1)
        V_half = truncate_matrix_half(V)
    elif ld_flag == 'y' and ld_file is None:
        V_half = simulate_ld_half(M, ld_const) # simulate with ld_const
    else:
        V_half = np.eye(M)

    print_func("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -", f)

    header = print_header(p_sim, h_sim, N, M, ld_const, ITS, sumstats_file=sumstats_file, ld_file=ld_file)
    print_func(header, f)

    # print header
    if fix_initial == 'y':
        print_func("Starting chain with fixed values...", f)
    else:
        print_func("Staring chain with random values...", f)

    print_func("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",f)

    print_func("LD const: %s" % ld_const, f)

    # simulate beta-hats
    if ivar == 'n':
        if sumstats_file is None:  # simulate
            z, c_true, gamma_true, p_true = simulate(p_sim, h_sim, N, M, V_half)
            print_func("True p: %.4f" % p_true, f)
            #print z
            #print c_true
        else:
            z = np.loadtxt(sumstats_file)
    else: # infinitesimal variance
        if sumstats_file is None:  # simulate
            print_func("Using infinitesimal variance...", f)
            z, c_true, gamma_true, p_true = simulate_ivar(p_sim, h_sim, N, M, V_half)
            print_func("True p: %.4f" % p_true, f)
            #np.savetxt("sumstats.txt", z)
            #print z
            #print c_true
        else:
            z = np.loadtxt(sumstats_file)

    # find true density value
    if sumstats_file is None:
        if ivar == 'n':
            true_map = joint_prob(p_true, c_true, gamma_true, h_sim, z, N, V_half)
        else:
            true_map = joint_prob_ivar(p_true, c_true, gamma_true, h_sim, z, N, V_half)

        print_func("True log-density: %.6g" % true_map, f)

    # fixed or random start
    if fix_initial == 'y' and sumstats_file is None:
        p_init = p_true
        c_init = list(c_true)
        gamma_init = list(gamma_true)
        if h_true is not None:
            h_init = h_true
        else:
            h_init = None
    else:
        p_init = None
        h_init = None
        c_init = None
        gamma_init = None

    # profile code for time-benchmarking
    if profile == "y":
        pr = cProfile.Profile()
        pr.enable()

    # Gibbs sampler to perform inference
    if ivar == 'n' and h_true is not None:
        p_est, gamma_est, c_est, est_log_like, p_list, density_list = \
            gibbs(z, h_true, N, M, V_half, p_init, c_init , gamma_init, its=ITS)
    elif ivar == 'y' and h_true is not None:
        p_est, p_var, gamma_est, c_est, est_log_like, p_list, density_list = \
            gibbs_ivar(z, h_true, N, M, V_half, p_init, c_init, gamma_init, its=ITS)
    elif ivar == 'y' and h_true is None: # infer h
        print "Going to infer h..."
        p_est, p_var, h_est, h_var, gamma_est, c_est, est_log_like, p_list, h_list, density_list = \
            gibbs_ivar_full(z, N, M, V_half, p_init, h_init, c_init, gamma_init, its=ITS)
    else:
        exit(1) # user has wrong flags

    if profile =="y":
        pr.disable()

    print_func("Estimate p: %.4f" % p_est, f)
    print_func("Variance p: %.4g" % p_var, f)

    if h_true is None: # estimating heritability
        print_func("Estimate h: %.4g" % h_est, f)
        print_func("Variance h: %.4g" % h_var, f)

    #prop_c = np.sum(c_est)/float(M)
    #print_func("Prop c: %.4f" % prop_c, f)
    print_func("Estimated log-like: %.6g" % est_log_like, f)

    # calculate correlation between simulated gammas and estimated gammas to measure how close estimates are to true values
    # corr ~ 1.0 --> gamma estimates are close to truth
    # corr ~ 0.0 --> gamma estmates are far from truth
    #gamma_corr = summarize_gamma(np.multiply(gamma_true, c_true), np.multiply(gamma_est, c_est), graph=plot)
    #print("Gamma corr: %.4f" % gamma_corr)

    # summarize results if okay to plot
    if plot == 'y':
        trace_plot(p_list, truth=p_sim, filename="fig.trace_p.png")
        trace_plot(density_list, truth=true_map,
                   filename="fig.trace_density.png", title="Value of density P(p | gamma, c, sigma_g, B)")
        hist_plot(p_list, p_true, filename="fig.hist_p.png")

        if h_true is None:
            trace_plot(h_list, truth=h_sim, filename="fig.trace_h.png")
            hist_plot(h_list, h_sim, filename="fig.hist_h.png")

    # profile code
    if profile == "y":
        s = StringIO.StringIO()
        sortby = 'cumulative'
        ps = pstats.Stats(pr, stream=s).sort_stats(sortby)
        ps.print_stats()
        print s.getvalue()


if __name__== "__main__":
  main()



