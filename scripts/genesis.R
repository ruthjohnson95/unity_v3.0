#!/usr/bin/env Rscript

library(GENESIS)
library("optparse")
library("pracma")

option_list = list(
  make_option(c("--p_sim"), type="double", metavar="character"),
  make_option(c("--sigG"), type="double", metavar="character"),
  make_option(c("--N"), type="integer", metavar="character"),
  make_option(c("--seed"), type="integer", metavar="character"),
  make_option(c("--gwas_dir"), type="character", metavar="character"),
  make_option(c("--outdir"), type="character", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

p_sim = opt$p_sim
sigG = opt$sigG
N = opt$N
seed = opt$seed
gwas_dir = opt$gwas_dir
outdir = opt$outdir

gwas_file = sprintf("p_%.4g_sigG_%.4g_N_%d_%d.gwas", p_sim, sigG, N, seed)

gwas<-read.table(paste(gwas_dir, gwas_file, sep='/'), header=T)
gwas_genesis<-data.frame(gwas$snp, gwas$z, gwas$n)
colnames(gwas_genesis)<-c('snp', 'z', 'n')

fit2 <- genesis(gwas_genesis, filter=F, modelcomponents=2, cores=2, LDcutoff=0.1, LDwindow=1, c0=10, startingpic=0.005)

est <- fit2$estimates$`Parameter (pic, sigmasq, a) estimates`
se<-fit2$estimates$`S.D. of parameter estimates`

pic_est = est[1]
pic_se = se[1]

sigG_est = est[2]
sigG_se = est[2]

outfile = paste(outdir, sprintf("p_%.4g_sigG_%.4g_N_%d_%d.genesis",
    p_sim, sigG, N, seed), sep='/')

pic_est_str=sprintf("PIC-est: %.4g\n", pic_est, file=outfile)
pic_se_str=sprintf("PIC-se: %.4f\n", pic_se, file=outfile)

sigG_est_str=sprintf("sigG-est: %.4g\n", sigG_est, file=outfile)
sigG_se_str=sprintf("sigG-se: %.4g\n", sigG_se, file=outfile)

cat(pic_est_str, file=outfile, append=TRUE)
cat(pic_se_str, file=outfile, append=TRUE)
cat(sigG_est_str, file=outfile, append=TRUE)
cat(sigG_se_str, file=outfile, append=TRUE)