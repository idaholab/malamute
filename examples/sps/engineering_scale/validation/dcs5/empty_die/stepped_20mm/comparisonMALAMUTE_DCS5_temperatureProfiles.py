#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jun  9 09:45:54 2023

@author: pittsa
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# user will need to update the directory to match current file location
directory = '~/'

malamute = pd.read_csv(
    directory + 'fourspacer_twopunch_diewall_threephysics_out.csv')
dcs5 = pd.read_csv(directory + 'DCS5_data.csv')
malamute.drop(index=0, inplace=True)
print(malamute)
print(dcs5)

# adjust the temperature to be in Kelvin
temp = dcs5.loc[:, 'temperature']
temp_k = temp.add(273, fill_value=100)
dcs5['temperature'] = temp_k
print(dcs5)

######################################
# plot the pyrometer measurement and point comparison

plt.figure()
ax1 = malamute.plot.line(x='time', y='pyrometer_point',
                         color='slategrey', label='Pyrometer point')
dcs5.plot.line(ax=ax1, x='time', y='temperature', linewidth=2,
               color='forestgreen', label='DCS-5 data')
plt.xlabel('Time (s)')
ax1.set_ylabel('Temperature (K)')
plt.title('Die wall MALAMUTE - Empty DCS-5 Comparison')


ax2 = malamute.plot.line(x='time', y='upper_plunger_step_point',
                         color='peru', marker='o', markevery=3, label='Upper plunger')
malamute.plot.line(ax=ax2, x='time', y='lower_plunger_step_point',
                   color='darkblue', label='Lower plunger')
dcs5.plot.line(ax=ax2, x='time', y='temperature', linewidth=2,
               color='forestgreen', label='DCS-5 data')
plt.xlabel('Time (s)')
ax2.set_ylabel('Temperature (K)')
plt.title('Plungers at step: MALAMUTE - Empty DCS-5 Comparison')

ax3 = malamute.plot.line(x='time', y='upper_plunger_center_point',
                         color='orange', marker='^', markevery=5, label='Upper plunger')
malamute.plot.line(ax=ax3, x='time', y='lower_plunger_center_point',
                   color='slateblue', label='Lower plunger')
dcs5.plot.line(ax=ax3, x='time', y='temperature', linewidth=2,
               color='forestgreen', label='DCS-5 data')
plt.xlabel('Time (s)')
ax3.set_ylabel('Temperature (K)')
plt.title('Near Center MALAMUTE - Empty DCS-5 Comparison')
