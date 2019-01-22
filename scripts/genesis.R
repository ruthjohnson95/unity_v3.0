#!/usr/bin/env Rscript

library(GENESIS)
library("optparse")
library("pracma")

option_list = list(
	    make_option(c("--gwas_file"), type="character", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

gwas_file = opt$gwas_file
#gwas_file = sprintf("p_%.4g_h2_%.4g_N_%d_%d.gwas", p_sim, sigG, N, seed)

gwas<-read.table(gwas_file, header=T)
gwas_genesis<-data.frame(gwas$snp, gwas$z, gwas$n)
colnames(gwas_genesis)<-c('snp', 'z', 'n')

fit2 <- genesis(gwas_genesis, filter=F, modelcomponents=2, cores=2, LDcutoff=0.1, LDwindow=1, c0=10, startingpic=0.005)

est <- fit2$estimates$`Parameter (pic, sigmasq, a) estimates`
se<-fit2$estimates$`S.D. of parameter estimates`

pic_est = est[1]
pic_se = se[1]

sigG_est = est[2]
sigG_se = se[2]

pic_est_str=sprintf("PIC-est: %.4g\n", pic_est)
pic_se_str=sprintf("PIC-se: %.4f\n", pic_se)

sigG_est_str=sprintf("sigG-est: %.4g\n", sigG_est)
sigG_se_str=sprintf("sigG-se: %.4g\n", sigG_se)

cat(pic_est_str)
cat(pic_se_str)
cat(sigG_est_str)
cat(sigG_se_str)