import pandas as pd 
import numpy as np 

all_summary_file="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/SUMMARY/ALL.summary.txt"

outfile="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/SUMMARY/ALL.summary.range.txt"

df = pd.read_csv(all_summary_file, sep=' ')

df['P_EST_RANGE'] = None

# In [14]  list1 =  df.index[df.loc[:, 'B'] > 0]


P_EST_4 = df.index[df.loc[:,'P_EST'] >= 0.05 ]
P_EST_3 = df.index[(df.loc[:,'P_EST'] < 0.05) & (df.loc[:,'P_EST'] >= 0.01) ]
P_EST_2 = df.index[(df.loc[:,'P_EST'] < 0.01) & (df.loc[:,'P_EST'] >= 0.001) ]
P_EST_1 = df.index[df.loc[:,'P_EST'] < 0.001 ]
P_EST_0 = df.index[df.loc[:,'P_EST'] == 0]

df.at[P_EST_4, 'P_EST_RANGE'] = ">0.05"
df.at[P_EST_3, 'P_EST_RANGE'] = "[0.01, 0.05)"
df.at[P_EST_2, 'P_EST_RANGE'] = "[0.001, 0.01)"
df.at[P_EST_1, 'P_EST_RANGE'] = "(0, 0.001)"
df.at[P_EST_0, 'P_EST_RANGE'] = "=0.0"

df.columns = ["TRAIT", "BLOCK", "CHR", "START", "STOP", "H2", "M", "P_EST", "P_EST_RANGE"]

df.to_csv(outfile, index=False)
