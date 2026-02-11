#!/opt/moose/miniconda/bin/python
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from matplotlib import rc
import matplotlib.patches as mpatches
import math
import glob, os

# Al's stuff
# import matplotlib as mpl
import numpy as np
from scipy import stats

SIZE = 14

plt.rc("font", size=SIZE)  # controls default text sizes
plt.rc("axes", titlesize=SIZE)  # fontsize of the axes title
plt.rc("axes", labelsize=SIZE)  # fontsize of the x and y labels
plt.rc("xtick", labelsize=SIZE)  # fontsize of the tick labels
plt.rc("ytick", labelsize=SIZE)  # fontsize of the tick labels
plt.rc("legend", fontsize=SIZE)  # legend fontsize
plt.rc("figure", titlesize=SIZE)  # fontsize of the figure title

stress_name = "vonmises_stress"
strain_name = "strain_yy"

fig = plt.figure(figsize=(3.5, 3))

df = pd.read_csv("t300.csv")
plt.plot(
    abs(df.loc[:, strain_name]) * 1e3,
    df.loc[:, stress_name] / 1e6,
    "-",
    color="red",
    alpha=1.0,
    linewidth=3,
    label="300",
)
df = pd.read_csv("t400.csv")
plt.plot(
    abs(df.loc[:, strain_name]) * 1e3,
    df.loc[:, stress_name] / 1e6,
    "-",
    color="blue",
    alpha=1.0,
    linewidth=3,
    label="400",
)
df = pd.read_csv("t500.csv")
plt.plot(
    abs(df.loc[:, strain_name]) * 1e3,
    df.loc[:, stress_name] / 1e6,
    "-",
    color="green",
    alpha=1.0,
    linewidth=3,
    label="500",
)
df = pd.read_csv("t600.csv")
plt.plot(
    abs(df.loc[:, strain_name]) * 1e3,
    df.loc[:, stress_name] / 1e6,
    "-",
    color="cyan",
    alpha=1.0,
    linewidth=3,
    label="600",
)


plt.ylabel("vM stress (MPa)")
plt.xlabel("strain (1e-3)")
# plt.legend(loc='best', shadow=True)

name = "isoPlastic_stressStrain.pdf"
fig.savefig(name, format="pdf", bbox_inches="tight", pad_inches=0.1)

# plt.show()
