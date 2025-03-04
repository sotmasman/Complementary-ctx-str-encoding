#!/bin/bash
# Array of argument variable names
# Iterate over the array

nsplits=5
iterations=1
while [ $iterations -le $nsplits ]; do
    for areaid in 1 2 3 6; do
        for arg in 100 ; do
            
      # Run MATLAB script with argument, load_data from is the last argument 1: dms, 2: m1, 3: mpfc 4:striatum_D1 5:striatum_D2, 6: dls
            ~/matlab_no_compile_submit_exclusive_change_dir.sh -t 12 -m 8 -d "/u/home/s/singlade/VLSE_neuro/population_movement_decoding" -f "svm_speed_classification_main_hoffman $arg 1 $areaid 0 $nsplits $iterations"
            sleep 2s
            
        done
    done
    ((iterations++))
done

nsplits=5
iterations=1
while [ $iterations -le $nsplits ]; do
    for areaid in 1 2 3 6; do
        for arg in 100 ; do
            
      # Run MATLAB script with argument, load_data from is the last argument 1: dms, 2: m1, 3: mpfc 4:striatum_D1 5:striatum_D2, 6: dls
            ~/matlab_no_compile_submit_exclusive_change_dir.sh -t 12 -m 8 -d "/u/home/s/singlade/VLSE_neuro/population_movement_decoding" -f "svm_speed_classification_main_hoffman $arg 1 $areaid 1 $nsplits $iterations"
            sleep 2s
            
        done
    done
    ((iterations++))
done