#!/usr/bin/env python

# /****************************************************************************/
# /*                        DO NOT MODIFY THIS HEADER                         */
# /*                                                                          */
# /* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
# /*                                                                          */
# /*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
# /*                           ALL RIGHTS RESERVED                            */
# /****************************************************************************/

# A script to process experimental data produced using the Dr. Sinter machine.

### Example Usage #########################################

# Run the script in the `malamute/scripts` directory:
#
#   % cd ~/projects/malamute/scripts
#   % python drsinter_data_extraction.py
#
# The script will query for extraction settings:
#
#   Dr. Sinter data file name (or complete file path): drsinter_example_data.csv
#   Smooth displacement data? (Y or N, Press ENTER/RETURN for Y):
#   How many data points should the smoothing window contain? (Press ENTER/RETURN for default = 100):
#   Plot extracted data? (Y or N, Press ENTER/RETURN for Y):
#   Exported plot format? (PNG or PDF, Press ENTER/RETURN for PDF):
#
# Blanks after the questions mean RETURN was pressed, and the default was used.
# The file can be provided as a local file name or a complete file path. `~` is
# expanded in the file path. For `drsinter_example_data.csv`, the following output
# is then provided on-screen:
#
#   Initial Dr. Sinter data file ( drsinter_example_data.csv ) import complete...
#
#  Note: if the script returns an error about unicode decoding, e.g.
#    " UnicodeDecodeError: 'utf-8' codec can't decode byte 0xb1 in position 1052: invalid start byte"
#  delete the first line of the data file, save, and try again. Generally this data file
#  modification allows the script to run as expected.
#
#
#   ####################
#   DATA SAMPLING INFORMATION
#   ####################
#   Data Sampling Rate (s) = 0.5
#   ####################
#   DATA UNITS
#   ####################
#   Units for VOLTAGE = V
#   Units for CURRENT = A
#   Units for TEMP. = deg C
#   Units for PRESSURE = kN
#   Units for Z-AXIS = mm
#   Units for VACUUM = Pa
#   Units for HIGH VACUUM = Pa
#   ####################
#   SMOOTHING INFORMATION
#   ####################
#   Smoothing for VOLTAGE = ON
#        Smoothing Points = 11
#   Smoothing for CURRENT = ON
#        Smoothing Points = 11
#   Smoothing for TEMP. = OFF
#   Smoothing for PRESSURE = OFF
#   Smoothing for Z-AXIS = OFF
#   Smoothing for VACUUM = OFF
#   Smoothing for HIGH VACUUM = OFF
#   ####################
#   DATA INFORMATION
#   ####################
#   Number of data points = 2959
#   Displacement smoothing (postprocess) = ON
#     Displacement smoothing window size = 100
#
#
#   Experimental data isolated. Processing time axis...
#   Time axis processed. END TIME = 1479.0 s
#   Checking for extra experimental data columns (to remove unintentional NaN values from initial import of ragged rows)...
#   Extraneous data columns removed. Setting sensible column values and row indices...
#   Experimental displacement data smoothed with 100 data points per averaging window...
#   Experimental data fully formatted. Exporting data file...
#   Data exported to drsinter_example_data_processed.csv
#   Metadata exported to drsinter_example_data_metadata.csv
#   Exported VOLTAGE.pdf
#   Exported CURRENT.pdf
#   Exported TEMP..pdf
#   Exported PRESSURE.pdf
#   Exported Z-AXIS.pdf
#   Exported VACUUM.pdf
#   Exported HIGH VACUUM.pdf
#
#
# Two CSV files are produced as output: (1) `drsinter_example_data_processed.csv`: contains
# the complete processed data for all data fields mentioned in the on-screen console output,
# and (2) `drsinter_example_data_metadata.csv`: contains a copy of the on-screen metadata.
# Then, depending on the options for plot export, PDF or PNG files will be produced for
# monitoring, usage in documents, etc.

##########################################################

### Python packages ######################################

import sys
import os
import pandas as pd
import re
import matplotlib.pyplot as plt

##########################################################

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
# Expands tilde character if used
data_file_path = os.path.expanduser(data_file_path)
data_file_base = os.path.basename(data_file_path)

smooth_disp_query = input(
    'Smooth displacement data? (Y or N, Press ENTER/RETURN for Y): ')
if smooth_disp_query == 'Y' or smooth_disp_query == 'y' or smooth_disp_query == 'Yes' or smooth_disp_query == 1 or smooth_disp_query == 'True':
    smooth_disp = True
elif smooth_disp_query == '':
    smooth_disp = True
elif smooth_disp_query == 'N' or smooth_disp_query == 'n' or smooth_disp_query == 'No' or smooth_disp_query == 0 or smooth_disp_query == 'False':
    smooth_disp = False
else:
    print('ERROR: Please input Yes or No for displacement data smoothing!')
    sys.exit(1)

if smooth_disp:
    disp_smoothing_window = input(
        'How many data points should the displacement smoothing window contain? (Press ENTER/RETURN for default = 100):')
    if disp_smoothing_window == '':
        disp_smoothing_window = 100
    else:
        disp_smoothing_window = int(disp_smoothing_window)

smooth_temperature_query = input(
    'Smooth temperature data? (Y or N, Press ENTER/RETURN for Y): ')
if smooth_temperature_query == 'Y' or smooth_temperature_query == 'y' or smooth_temperature_query == 'Yes' or smooth_temperature_query == 1 or smooth_temperature_query == 'True':
    smooth_temperature = True
elif smooth_temperature_query == '':
    smooth_temperature = True
elif smooth_temperature_query == 'N' or smooth_temperature_query == 'n' or smooth_temperature_query == 'No' or smooth_temperature_query == 0 or smooth_temperature_query == 'False':
    smooth_temperature = False
else:
    print('ERROR: Please input Yes or No for displacement data smoothing!')
    sys.exit(1)

if smooth_temperature:
    temp_smoothing_window = input(
        'How many data points should the temperature smoothing window contain? (Press ENTER/RETURN for default = 100):')
    if temp_smoothing_window == '':
        temp_smoothing_window = 100
    else:
        temp_smoothing_window = int(temp_smoothing_window)

plot_query = input('Plot extracted data? (Y or N, Press ENTER/RETURN for Y): ')
if plot_query == 'Y' or plot_query == 'Yes' or plot_query == 'y' or plot_query == 1 or plot_query == 'True':
    plot_data = True
elif plot_query == '':
    plot_data = True
elif plot_query == 'N' or plot_query == 'No' or plot_query == 'n' or plot_query == 0 or plot_query == 'False':
    plot_data = False
else:
    print('ERROR: Please input Yes or No for data plot export!')
    sys.exit(1)

if plot_data:
    plot_format_query = input(
        'Exported plot format? (PNG or PDF, Press ENTER/RETURN for PDF): ')
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
    col_count = [len(l.split(",")) for l in temp.readlines()]
dummy_names = [i for i in range(0, max(col_count))]

# Build data lists
raw_data = []

raw_data.append(pd.read_csv(
    data_file_base, on_bad_lines='skip', names=dummy_names))
print("Initial Dr. Sinter data file (", data_file_base, ") import complete...")

# Create empty dataframe that will be used to house metadata for later export
metadata = pd.DataFrame(columns=[0, 1])

vertical_space(2)
header_print('DATA SAMPLING INFORMATION')

# Find sampling rate (in order to set data time axis)
sampling_row = raw_data[0].loc[raw_data[0]
                               [dummy_names[0]] == 'Unit Sampling Rate']
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

# Get channel names (with NaN for missing column entries)
channel_row = raw_data[0].loc[raw_data[0][dummy_names[0]] == 'Waveform Name']

header_print('DATA UNITS')

# Get units for each channel
units_row = raw_data[0].loc[raw_data[0][dummy_names[0]] == 'Unit']
for i in range(1, len(units_row.columns)):
    curr_unit = units_row.iloc[0][i]
    curr_channel = channel_row.iloc[0][i]
    if isNaN(curr_unit) == False:
        # removes non-ASCII characters (as is the case with the temperature unit)
        curr_unit = ''.join(i for i in curr_unit if ord(i) < 128)
        if curr_unit == 'C':
            curr_unit = 'deg C'
            units_row.iat[0, i] = curr_unit
        print('Units for', curr_channel, '=', curr_unit)
        metadata.loc[i] = ['Units for ' + curr_channel, curr_unit]

header_print('SMOOTHING INFORMATION')

# Is smoothing on for each channel? If so, print how many points used.
smoothing_row = raw_data[0].loc[raw_data[0][dummy_names[0]] == 'Smoothing']
smoothing_points_row = raw_data[0].loc[raw_data[0]
                                       [dummy_names[0]] == 'No. of Points']
j = 0
for i in range(1, len(smoothing_row.columns)):
    curr_state = smoothing_row.iloc[0][i]
    curr_channel = channel_row.iloc[0][i]
    curr_sample_points = smoothing_points_row.iloc[0][i]
    if isNaN(curr_state) == False:
        print('Smoothing for', curr_channel, '=', curr_state)
        metadata.loc[i+len(units_row.columns) +
                     j] = ['Smoothing for ' + curr_channel, curr_state]
        if curr_state == 'ON':
            j += 1
            print('     Smoothing Points =', curr_sample_points)
            metadata.loc[i+len(units_row.columns)+j] = [curr_channel +
                                                        ' smoothing points (#)', curr_sample_points]

header_print('DATA INFORMATION')

# Isolate experimental data in new DataFrame
# Find '#EndHeader' row to get beginning point for data
end_header_row_index = raw_data[0].loc[raw_data[0]
                                       [dummy_names[0]] == '#EndHeader'].index[0]
data_index_start = end_header_row_index + 1
# Find '#BeginMark' row to get end point for data
data_index_end = raw_data[0].loc[raw_data[0]
                                 [dummy_names[0]] == '#BeginMark'].index[0]
# Isolate experimental data
exp_data = raw_data[0].loc[range(data_index_start, data_index_end)]
print('Number of data points =', len(exp_data))

metadata.loc[len(units_row.columns)+len(smoothing_row.columns) +
             j+1] = ['Number of data points (#)', len(exp_data)]

# If displacement smoothing was selected (default is True)
if smooth_disp:
    print('Displacement smoothing (postprocess) = ON')
    print('  Displacement smoothing window size =', disp_smoothing_window)
    metadata.loc[len(units_row.columns)+len(smoothing_row.columns) +
                 j+2] = ['Displacement smoothing (postprocess)', 'ON']
    metadata.loc[len(units_row.columns)+len(smoothing_row.columns)+j +
                 3] = ['Displacement smoothing window size', disp_smoothing_window]

# If temperature smoothing was selected (default is True)
if smooth_temperature:
    print('Temperature smoothing (postprocess) = ON')
    print('  Temperature smoothing window size =', temp_smoothing_window)
    metadata.loc[len(units_row.columns)+len(smoothing_row.columns) +
                 j+4] = ['Temperature smoothing (postprocess)', 'ON']
    metadata.loc[len(units_row.columns)+len(smoothing_row.columns)+j +
                 5] = ['Temperature smoothing window size', temp_smoothing_window]

vertical_space(2)
print('Experimental data isolated. Processing time axis...')

# Remove date sample column and set microsecond time column to new time values
# based on sampling rate
exp_data = exp_data.drop(columns=[0])
for i in range(0, len(exp_data)):
    if i == 0:
        exp_data.iat[i, 0] = 0
    else:
        exp_data.iat[i, 0] = exp_data.iat[i-1, 0] + sampling_rate

print('Time axis processed. END TIME =', exp_data.iat[len(exp_data)-1, 0], 's')
print('Checking for extra experimental data columns (to remove unintentional NaN values from initial import of ragged rows)...')

# Check for and remove columns with NaNs
removal_list = []
for i in range(0, len(exp_data.columns)):
    curr_entry = exp_data.iat[0, i]
    if isNaN(curr_entry):
        removal_list.append(exp_data.columns[i])
exp_data = exp_data.drop(columns=removal_list)

print('Extraneous data columns removed. Setting sensible column values and row indices...')

# Modify channel row labels and replace exp_data dataframe dummy column labels
# Remove raw data row label, set empty cell to TIME, and remove same columns from removal_list
channel_row = channel_row.drop(columns=[0])
channel_row.iat[0, 0] = 'TIME'
channel_row = channel_row.drop(columns=removal_list)
# Initialize empty list
new_labels = []
for i in range(0, len(channel_row.columns)):
    new_labels.append(channel_row.iat[0, i])
# Replace exp_data column names with new labels
rename_dict = {exp_data.columns[i]: new_labels[i]
               for i in range(len(new_labels))}
exp_data = exp_data.rename(columns=rename_dict)

# Modify row indices in experimental data to start from zero (for ease of plotting)
# Initialize empty list
new_row_indices = []
for i in range(0, len(exp_data.index)):
    new_row_indices.append(i)
# Replace exp_data row indices with new ones
reindex_dict = {exp_data.index[i]: new_row_indices[i]
                for i in range(len(new_row_indices))}
exp_data = exp_data.rename(reindex_dict)

# Smooth displacement data
if smooth_disp:
    exp_data['Z-AXIS'] = exp_data['Z-AXIS'].rolling(
        window=disp_smoothing_window, min_periods=1, center=True).mean()
    print('Experimental displacement data smoothed with',
          disp_smoothing_window, 'data points per averaging window...')

# Smooth temperature data
if smooth_temperature:
    exp_data['TEMP.'] = exp_data['TEMP.'].rolling(
        window=temp_smoothing_window, min_periods=1, center=True).mean()
    print('Experimental temperature data smoothed with',
          temp_smoothing_window, 'data points per averaging window...')
#########################################################

### DATA EXPORT #########################################

print('Experimental data fully formatted. Exporting data file...')

# Create new base filename based on given raw data file
name_base = os.path.splitext(data_file_base)[0]
name_suffix = '_processed.csv'
export_name = name_base + name_suffix
exp_data.to_csv(export_name, index=False)

print('Data exported to', export_name)

# Export metadata
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
        exp_data.plot(ax=ax1, x='TIME', y=cols[i], color=color_and_marker[0][0], marker=color_and_marker[0][1], markerfacecolor=color_and_marker[0][2], markevery=int(
            color_and_marker[0][3]), xlabel='Time (s)', ylabel=(cols[i]+' (' + units[i] + ')'))
        ax1.relim()
        ax1.autoscale_view()
        for line in ax1.lines:
            line.set_marker('')
        ax1.get_legend().remove()
        plt.tight_layout(pad=2)
        plt.savefig(name_base + cols[i] + plot_format)
        print('Exported', name_base + cols[i] + plot_format)
        plt.cla()

#########################################################
