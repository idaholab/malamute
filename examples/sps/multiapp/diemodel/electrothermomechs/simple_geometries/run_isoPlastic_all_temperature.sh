#!/bin/bash
../../../../../malamute-opt -i isoPlastic_singleblock.i "initial_temperature=300 Outputs/file_base=t300" &
../../../../../malamute-opt -i isoPlastic_singleblock.i "initial_temperature=400 Outputs/file_base=t400" &
../../../../../malamute-opt -i isoPlastic_singleblock.i "initial_temperature=500 Outputs/file_base=t500" &
../../../../../malamute-opt -i isoPlastic_singleblock.i "initial_temperature=600 Outputs/file_base=t600" 
