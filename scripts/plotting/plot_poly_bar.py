#!/usr/bin/env python
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import os
import numpy as np 
import sys 

sns.set(color_codes=True)

results_file="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/height/height.summary.txt"
df = pd.read_csv(results_file, sep=' ')

p_arr = df["P_EST"].values

import numpy as np
import matplotlib.pyplot as plt


data = [[ 35, 73,  133, 761,  144],
        [ 58230, 381139,  78045,  99308, 160454],
        [ 89135,  80552, 152558, 497981, 603535],
        [ 78415,  81858, 150656, 193263,  69638],
        [139361, 331509, 343164, 781380,  52269]]

columns = ('Freeze', 'Wind', 'Flood', 'Quake', 'Hail')
rows = ['%d year' % x for x in (100, 50, 20, 10, 5)]

values = np.arange(0, 2500, 500)
value_increment = 1000

# Get some pastel shades for the colors
colors = plt.cm.BuPu(np.linspace(0, 0.5, len(rows)))
n_rows = len(data)

index = np.arange(len(columns)) + 0.3
bar_width = 0.4

# Initialize the vertical-offset for the stacked bar chart.
y_offset = np.zeros(len(columns))

# Plot bars and create text labels for the table
cell_text = []
for row in range(n_rows):
    plt.bar(index, data[row], bar_width, bottom=y_offset, color=colors[row])
    y_offset = y_offset + data[row]
    cell_text.append(['%1.1f' % (x / 1000.0) for x in y_offset])
# Reverse colors and text labels to display the last value at the top.
colors = colors[::-1]
cell_text.reverse()

# Add a table at the bottom of the axes
the_table = plt.table(cellText=cell_text,
                      rowLabels=rows,
                      rowColours=colors,
                      colLabels=columns,
                      loc='bottom')

# Adjust layout to make room for the table:
plt.subplots_adjust(left=0.2, bottom=0.2)

plt.ylabel("Loss in ${0}'s".format(value_increment))
plt.yticks(values * value_increment, ['%d' % val for val in values])
plt.xticks([])
plt.title('Loss by Disaster')

plt.savefig("testfig.pdf")

"""
trait=sys.argv[0]

if trait is None:
    print "ERROR: need to specify trait"
    exit(1)

outdir="/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/%s" % trait

for block_size in ["6mb", "12mb", "24mb", "48mb"]:
    results_file = "/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/height/%s/summary_h2_poly.txt" % block_size

    df = pd.read_csv(results_file, sep=' ')

    chr_colors = []

    for index, row in df.iterrows():
        if row['CHR'] % 2 == 0:
            chr_colors.append('black')
        else:
            chr_colors.append('blue')

    H2_cutoff=0
    M_cutoff=0

    # drop nans
    df = df.dropna()
    df_filter = df.loc[(df['M'] >= M_cutoff) & (df['H2'] >= H2_cutoff) ]
    p_est = df_filter['P_EST']
    h2 = df_filter['H2']
    M = df_filter['M']

    # get xticks for chr
    chr_ticks = []
    for chr in range(1,23):
        chr_tick = np.median(df_filter.loc[df['CHR']==chr].index)
        chr_ticks.append(chr_tick)

    B = len(p_est)

    # compute correlation between H2 and P
    corr = np.corrcoef(h2, p_est)[0,1]
    print "Correlation-%s: %.4g" % (block_size, corr)

    # average block size
    avg_M = np.mean(M)
    print "Avg M-%s: %.4g" % (block_size, avg_M)
    
    # average h^2
    avg_h2 = np.mean(h2)
    print "Avg h2-%s: %.4g" % (block_size, avg_h2)

    # average p
    avg_p = np.mean(p_est)
    print "Avg p-%s: %.4g" % (block_size, avg_p)

    # plot the per-SNP h2
    per_SNP_h2 = np.divide(h2, np.multiply(p_est, M))

    fig, ax = plt.subplots(2, sharex=True)
    ax[0].bar(range(0, B), p_est, width=1.0, color=chr_colors)
    ax[0].set_title("Proportion of causals - %s" % block_size)

    ax[1].bar(range(0, B), per_SNP_h2, width=1.0, color=chr_colors)
    ax[1].xaxis.set_ticks(chr_ticks)
    ax[1].xaxis.set_ticklabels(np.arange(22)+1, fontsize=5)
    ax[1].set_title("Estimated per-SNP h2 - %s" % block_size)

    plt.savefig(os.path.join(outdir, "manhattan_%s.pdf") % block_size)
    plt.close()

"""
