#!/usr/bin/env Rscript  

# summary file 
sum_file <- "/u/flashscratch/r/ruthjohn/ukbb_height_exp/final_results/summary.txt"
outfile <- "/u/flashscratch/r/ruthjohn/ukbb_height_exp/final_results/summary_chr_height.txt"

df<-read.table(sum_file, header=T, sep=' ')

# make outfile 
heading <- "chr,p,p_sd,sigma_g,sigma_g_sd,M_c"

cat(heading,file=outfile,sep="\n")

# find prop per chrom
for(i in 1:22)
{
	inds <- which(df$chr_N == i)
	
	p_chr = 0
	sigma_g_chr = 0 
	M_chr = 0 
	sd_chr = 0 
	M_causal = 0 
	sigma_g_sd = 0

	for(ind in inds)
	{
		p_ind=df$p[ind]
		sd_ind = df$sd_p[ind]

		M_ind=df$M[ind]
		sigma_g_ind=df$sigma_g[ind]
		sigma_g_sd_ind=df$sd_sigma_g[ind]		

		M_chr=M_chr + M_ind
		p_chr = p_chr + p_ind*M_ind 
		sd_chr = sd_chr + sd_ind*M_ind*p_ind

		sigma_g_chr = sigma_g_chr + sigma_g_ind*M_ind*p_ind  		
		sigma_g_sd = sigma_g_sd + sigma_g_sd_ind*M_ind*p_ind
		M_causal = M_causal + M_ind*p_ind 
	}

	#N=length(inds)
	
	p_chr = p_chr/M_chr
	sd_chr = sd_chr/(M_causal)
	sigma_g_sd = sigma_g_sd/M_causal 	

#	print(p_chr)
#	print(sd_chr)
#	print(sigma_g_chr)
	
	cat(sprintf("%d,%.4g,%.4g,%.4g,%.4g,%f",i,p_chr, sd_chr, sigma_g_chr, sigma_g_sd, M_causal ), file=outfile,sep="\n", append=T)

}	


# find sum sigma_g per chrom 

