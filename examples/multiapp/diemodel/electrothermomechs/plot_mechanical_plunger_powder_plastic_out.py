#!/opt/moose/miniconda/bin/python
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from matplotlib import rc
import matplotlib.patches as mpatches
import math
import glob, os
#Al's stuff
# import matplotlib as mpl
import numpy as np
from scipy import stats

SIZE=8

plt.rc('font', size=SIZE)          # controls default text sizes
plt.rc('axes', titlesize=SIZE)     # fontsize of the axes title
plt.rc('axes', labelsize=SIZE)    # fontsize of the x and y labels
plt.rc('xtick', labelsize=SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=SIZE)    # legend fontsize
plt.rc('figure', titlesize=SIZE)  # fontsize of the figure title



fig,ax = plt.subplots(figsize=(3.5, 3))

df=pd.read_csv('mechanical_plunger_powder_plastic_out.csv')
ax.plot(df.loc[:,'time'],\
         df.loc[:,'powder_max_vonmises_stress']/1e6,\
        '-', color='red', alpha=1.0, linewidth=3, label='300')
ax.set_ylabel('vM stress (MPa)',color='red')
ax.set_xlabel('time (s)')
ax.tick_params(axis='y', colors='red')


ax2=ax.twinx()
ax2.plot(df.loc[:,'time'],\
         df.loc[:,'powder_temperature_pp'],\
        '-', color='blue', alpha=1.0, linewidth=3, label='300')
ax2.set_ylabel('Temperature (C)',color='blue')
ax2.tick_params(axis='y', colors='blue')

# powder_temperature_pp



# plt.legend(loc='best', shadow=True)

name='isoPlastic_stressStrain.pdf'
fig.savefig(name, format='pdf', bbox_inches='tight', pad_inches=0.1)

# plt.show()
