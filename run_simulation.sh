#!/usr/bin/env sh 

sim_yaml=$1 

# parse simulation parameters from input file 
SIM_NAME=$(cat $sim_yaml | grep "SIM NAME" | cut -d':' -f2 | tr -d " \t\n\r" )
H_SIM=$(cat $sim_yaml | grep "HERITABILITY" | cut -d':' -f2 | tr -d " \t\n\r" )
P_SIM=$(cat $sim_yaml | grep "P SIM" | cut -d':' -f2 | tr -d " \t\n\r" )
N=$(cat $sim_yaml | grep "SAMPLE SIZE" | cut -d':' -f2 | tr -d " \t\n\r" )
BLOCKS=$(cat $sim_yaml | grep "BLOCKS" | cut -d':' -f2 | tr -d " \t\n\r" )
SEED=$(cat $sim_yaml | grep "SEED" | cut -d':' -f2 | tr -d " \t\n\r" )


echo $SIM_NAME
echo $H_SIM
echo $P_SIM
echo $N
echo $BLOCKS
echo $SEED

# make simulation dir 

# generate sample gwas 
