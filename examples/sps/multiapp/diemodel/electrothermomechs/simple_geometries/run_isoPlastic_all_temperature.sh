#!/bin/bash
../../../../../freya-opt -i isoPlastic_singleblock.i "initial_temperature=300 Outputs/file_base=t300" &
../../../../../freya-opt -i isoPlastic_singleblock.i "initial_temperature=400 Outputs/file_base=t400" &
../../../../../freya-opt -i isoPlastic_singleblock.i "initial_temperature=500 Outputs/file_base=t500" &
../../../../../freya-opt -i isoPlastic_singleblock.i "initial_temperature=600 Outputs/file_base=t600" 
