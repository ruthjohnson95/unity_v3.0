

"""
helper.py

Describes auxilary functions and constants used in main.py and mcmc.py

"""

def print_header(id, H, N, ITS, seed, gwas_dir, ld_half_dir, outdir, f):

    print_func("- - - - - - - - - - UNITY v3.0 - - - - - - - - -", f)

    print_func("Run id: %s" % id, f)
    print_func("Heritability: %.4f" % H , f)
    print_func("Sample size: %d" % N, f)
    print_func("Iterations: %d" % ITS, f)
    print_func("Seed: %d" % seed, f)
    print_func("Getting effect sizes from: %s" % gwas_dir, f)
    print_func("Using ld  from dir: %s" % ld_half_dir, f)
    print_func("Outputing simulated gwas to dir: %s" % outdir, f)

    print_func("- - - - - - - - - - - - - - - - - - - - - - - -", f)

    return