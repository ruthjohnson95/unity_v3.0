from unity_gibbs import *
import pandas as pd 

def main():
    parser = OptionParser()
    parser.add_option("--s", "--seed", dest="seed", default="7")
    parser.add_option("--ld_list", dest="ld_list_fname", default="ld_list.txt")
    parser.add_option("--z_list", dest="z_list_fname", default="z_list.txt")
    parser.add_option("--N", dest="N", default=500000)
    parser.add_option("--H", dest="H", default=0.01)
    parser.add_option("--ITS", dest="ITS", default=1000)

    (options, args) = parser.parse_args()

    seed = int(options.seed)
    ITS = int(options.ITS)
    np.random.seed(seed)

    ld_list_fname = np.loadtxt(options.ld_list_fname, dtype=str)
    z_list_fname = np.loadtxt(options.z_list_fname, dtype=str)

    if ld_list_fname.size != z_list_fname.size:
        print("ERROR: ld list and z-score list are of different size!")
        print("exiting...")
        exit(1)

    ld_list = []
    z_list = []
    M_list = []

    ld_half_list = []
    z_twiddle_list = []

    N = int(options.N)
    H = float(options.H)
    B = len(ld_list_fname)
    

    # load data for each block
    for b in range(0, B):
        max_z_b = max(np.asarray(pd.read_csv(z_list_fname[b], sep=' ', usecols=["Z"])))

        print(max_z_b[0])

        if max_z_b[0] >= 2.0:

            ld_b_half = np.loadtxt(ld_list_fname[b])
            ld_list.append(ld_b_half)

            z_b = pd.read_csv(z_list_fname[b], sep=' ', usecols=["BETA_STD"])
            z_list.append(z_b)

            M_b = len(z_b)
            M_list.append(M_b)

    print("Total number of blocks with passing zscore: %d" % len(z_list))
    B = len(z_list)

    for b in range(0, B):
        # neg half LD 
        ld_b_neg_half = truncate_matrix_neg_half(ld_list[b])

        # half LD 
        ld_b_half = truncate_matrix_half(ld_list[b])

        # transform betas 
        z_b_twiddle = np.matmul(ld_b_neg_half, z_list[b])

        # save to lists 
        ld_half_list.append(ld_b_half)
        z_twiddle_list.append(z_b_twiddle)

  #  np.save("ld_half_list", ld_half_list)
  #  np.save("z_twiddle_list", z_twiddle_list)

 

#    ld_half_list = np.load("/u/home/r/ruthjohn/ruthjohn/UNITY_gw/data_pipeline/scripts/ld_half_list.npy")
 #   z_twiddle_list = np.load("/u/home/r/ruthjohn/ruthjohn/UNITY_gw/data_pipeline/scripts/z_twiddle_list.npy")

    M_sum = np.sum(M_list)
    filename = "data_test" + str(seed) + ".log"
    f = open(filename, 'w')

    h_list= [H/float(M_sum)]*B
    print(h_list)

    p_est, p_var, p_list = gibbs_ivar_gw(z_twiddle_list, h_list, N, ld_half_list, its=ITS)

    print_func("Estimate p: %.4f" % p_est, f)
    print_func("SD p: %.4g" % math.sqrt(p_var), f)


if __name__== "__main__":
  main()
