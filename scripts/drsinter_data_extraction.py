#!/usr/bin/env python

import sys
import os
import pandas as pd
import re
import matplotlib.pyplot as plt

### Useful helper functions ##############################

# Helper function for adding some vertical space
def vertical_space(num):
    for i in range(0, num):
        print('')

# Helper function for printing section headers
def header_print(string):
    accent_string = '####################'
    print(accent_string)
    print(string)
    print(accent_string)

# Helper function for detecting NaN in strings
def isNaN(string):
    # Use property of NaN (NaN != NaN) in order to detect
    return string != string

#########################################################

### SCRIPT I/O ##########################################

data_file_path = input('Dr. Sinter data file name (or complete file path): ')
data_file_path = os.path.expanduser(data_file_path) # Expands tilde character if used
data_file_base = os.path.basename(data_file_path)

plot_query = input('Plot extracted data? (Y or N, Press ENTER/RETURN for Y): ')
if plot_query == 'Y' or plot_query == 'Yes' or plot_query == 1 or plot_query == 'True':
    plot_data = True
elif plot_query == '':
    plot_data = True
elif plot_query == 'N' or plot_query == 'No' or plot_query == 0 or plot_query == 'False':
    plot_data = False
else:
    print('ERROR: Please input Yes or No for data plot export!')
    sys.exit(1)

if plot_data:
    plot_format_query = input('Exported plot format? (PNG or PDF, Press ENTER/RETURN for PDF): ')
    if plot_format_query == 'PNG':
        plot_format = '.png'
    elif plot_format_query == 'PDF' or plot_format_query == '':
        plot_format = '.pdf'
    else:
        print('ERROR: Please input PNG or PDF for data plot export format!')
        sys.exit(1)

#########################################################

### DATA PROCESSING #####################################

# Need longest column length so that we can properly fill in "missing" fields for
# ragged rows (using names listed in dummy_names). See https://stackoverflow.com/q/27020216
# NOTE ON OPTIONS: Ignores any errors occuring during readlines (specifically
# utf-8 decode errors), since we're not extracting data here, only checking line
# lengths
with open(data_file_path, 'r', errors='ignore') as temp:
    # get number of columns in each line
    col_count = [ len(l.split(",")) for l in temp.readlines() ]
dummy_names = [i for i in range(0, max(col_count))]

# Build data lists
raw_data = []

raw_data.append(pd.read_csv(data_file_base, names=dummy_names))
print("Initial Dr. Sinter data file (", data_file_base, ") import complete...")

# Create empty dataframe that will be used to house metadata for later export
metadata = pd.DataFrame(columns = [0, 1])

vertical_space(2)
header_print('DATA SAMPLING INFORMATION')

### Find sampling rate (in order to set data time axis)
sampling_row = raw_data[0].loc[raw_data[0][dummy_names[0]] == 'Unit Sampling Rate']
sampling_str = sampling_row.iloc[0][1]
# Extract sampling rate integer
sampling_rate = int(re.findall(r'\d+', sampling_str)[0])
# Extract sampling rate unit
sampling_rate_unit = ''.join([i for i in sampling_str if not i.isdigit()])
# check sampling_rate_unit to find proper scaling factor for final sampling rate (in sec)
if sampling_rate_unit == 'ms':
    sampling_rate_factor = 0.001
if sampling_rate_unit != 'ms':
    print("ERROR: Undefined sampling rate unit.")
    sys.exit(1)

sampling_rate *= sampling_rate_factor

print('Data Sampling Rate (s) =', sampling_rate)

metadata.loc[0] = ['Data Sampling Rate (s)', sampling_rate]

### Get channel names (with NaN for missing column entries)
channel_row = raw_data[0].loc[raw_data[0][dummy_names[0]] == 'Waveform Name']

header_print('DATA UNITS')

### Get units for each channel (TODO: remove weird non-standard character in front of C for temp)
units_row = raw_data[0].loc[raw_data[0][dummy_names[0]] == 'Unit']
for i in range(1, len(units_row.columns)):
    curr_unit = units_row.iloc[0][i]
    curr_channel = channel_row.iloc[0][i]
    if isNaN(curr_unit) == False:
        curr_unit = ''.join(i for i in curr_unit if ord(i)<128) # removes non-ASCII characters (as is the case with the temperature unit)
        if curr_unit == 'C':
            curr_unit = 'deg C'
            units_row.iat[0, i] = curr_unit
        print('Units for', curr_channel, '=', curr_unit)
        metadata.loc[i] = ['Units for ' + curr_channel, curr_unit]

header_print('SMOOTHING INFORMATION')

### Is smoothing on for each channel? If so, print how many points used.
smoothing_row = raw_data[0].loc[raw_data[0][dummy_names[0]] == 'Smoothing']
smoothing_points_row = raw_data[0].loc[raw_data[0][dummy_names[0]] == 'No. of Points']
j = 0
for i in range(1, len(smoothing_row.columns)):
    curr_state = smoothing_row.iloc[0][i]
    curr_channel = channel_row.iloc[0][i]
    curr_sample_points = smoothing_points_row.iloc[0][i]
    if isNaN(curr_state) == False:
        print('Smoothing for', curr_channel, '=', curr_state)
        metadata.loc[i+len(units_row.columns)+j] = ['Smoothing for ' + curr_channel, curr_state]
        if curr_state == 'ON':
            j += 1
            print('     Smoothing Points =', curr_sample_points)
            metadata.loc[i+len(units_row.columns)+j] = [curr_channel + ' smoothing points (#)', curr_sample_points]

header_print('DATA INFORMATION')

### Isolate experimental data in new DataFrame
# Find '#EndHeader' row to get beginning point for data
end_header_row_index = raw_data[0].loc[raw_data[0][dummy_names[0]] == '#EndHeader'].index[0]
data_index_start = end_header_row_index + 1
# Find '#BeginMark' row to get end point for data
data_index_end = raw_data[0].loc[raw_data[0][dummy_names[0]] == '#BeginMark'].index[0]
# Isolate experimental data
exp_data = raw_data[0].loc[range(data_index_start, data_index_end)]
print('Number of data points =', len(exp_data))

metadata.loc[len(units_row.columns)+len(smoothing_row.columns)+j+1] = ['Number of data points (#)', len(exp_data)]

vertical_space(2)
print('Experimental data isolated. Processing time axis...')

### Remove date sample column and set microsecond time column to new time values
### based on sampling rate
exp_data = exp_data.drop(columns=[0])
for i in range(0, len(exp_data)):
    if i == 0:
        exp_data.iat[i, 0] = 0
    else:
        exp_data.iat[i, 0] = exp_data.iat[i-1, 0] + sampling_rate

print('Time axis processed. END TIME =', exp_data.iat[len(exp_data)-1,0], 's')
print('Checking for extra experimental data columns (to remove unintentional NaN values from initial import of ragged rows)...')

### Check for and remove columns with NaNs
removal_list = []
for i in range(0, len(exp_data.columns)):
    curr_entry = exp_data.iat[0, i]
    if isNaN(curr_entry):
        removal_list.append(exp_data.columns[i])
exp_data = exp_data.drop(columns=removal_list)

print('Extraneous data columns removed. Setting sensible column values and row indices...')

### Modify channel row labels and replace exp_data dataframe dummy column labels
# Remove raw data row label, set empty cell to TIME, and remove same columns from removal_list
channel_row = channel_row.drop(columns=[0])
channel_row.iat[0, 0] = 'TIME'
channel_row = channel_row.drop(columns=removal_list)
# Initialize empty list
new_labels = []
for i in range(0, len(channel_row.columns)):
    new_labels.append(channel_row.iat[0, i])
# Replace exp_data column names with new labels
rename_dict = {exp_data.columns[i]: new_labels[i] for i in range(len(new_labels))}
exp_data = exp_data.rename(columns=rename_dict)

### Modify row indices in experimental data to start from zero (for ease of plotting)
# Initialize empty list
new_row_indices = []
for i in range(0, len(exp_data.index)):
    new_row_indices.append(i)
# Replace exp_data row indices with new ones
reindex_dict = {exp_data.index[i]: new_row_indices[i] for i in range(len(new_row_indices))}
exp_data = exp_data.rename(reindex_dict)

#########################################################

### DATA EXPORT #########################################

print('Experimental data fully formatted. Exporting data file...')

### Create new base filename based on given raw data file
name_base = os.path.splitext(data_file_base)[0]
name_suffix = '_processed.csv'
export_name = name_base + name_suffix
exp_data.to_csv(export_name, index=False)

print('Data exported to', export_name)

### Export metadata
metadata_suffix = '_metadata.csv'
metadata_export_name = name_base + metadata_suffix
metadata.to_csv(metadata_export_name, index=False, header=False)
print('Metadata exported to', metadata_export_name)

#########################################################

### OPTIONAL DATA PLOTTING ##############################

if plot_data:
    # Set a selection of colors and markers for later usage
    color_and_marker = [['dodgerblue', 'v', 'dodgerblue', '1'],
                        ['slateblue', 'X', 'slateblue', '1'],
                        ['orange', 'D', 'orange', '51'],
                        ['forestgreen', 'o', 'forestgreen', '1'],
                        ['dimgray', 'o', 'dimgray', '1']]
    # Get column headers
    cols = exp_data.columns
    units = units_row
    units = units.drop(columns=[0])
    units.iat[0, 0] = 's'
    units = units.drop(columns=removal_list)
    units = units.iloc[0].values

    # Make sure all data is considered numeric
    exp_data = exp_data.astype(float)

    fig1, ax1 = plt.subplots()
    for i in range(1, len(cols)):
        exp_data.plot(ax = ax1, x = 'TIME', y=cols[i], color = color_and_marker[0][0], marker = color_and_marker[0][1], markerfacecolor = color_and_marker[0][2], markevery = int(color_and_marker[0][3]), xlabel='Time (s)', ylabel=(cols[i]+' (' + units[i] + ')'))
        ax1.relim()
        ax1.autoscale_view()
        for line in ax1.lines:
            line.set_marker(None)
        ax1.get_legend().remove()
        plt.tight_layout(pad=2)
        plt.savefig(cols[i] + plot_format)
        print('Exported', cols[i] + plot_format)
        plt.cla()

#########################################################
