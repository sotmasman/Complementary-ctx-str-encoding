# run_svm_start_results


for bin_size in 3; do
    for time_range in 3; do
        for areaid in 1 2 3 6; do
            for arg in 200 150 100 50 25; do
             # Run MATLAB script with argument, load_data from is the last argument 1: striatum, 2: m1, 3: pfc 4:striatum_D1 5:striatum_D2 6:dls
              ~/matlab_no_compile_submit_exclusive_change_dir.sh -t 22 -m 8 -d "/u/home/s/singlade/VLSE_neuro/population_movement_decoding" -f "svm_limb_move_classification_main_hoffman $arg 1 $areaid 0 $bin_size $time_range"
                sleep 2s
            done
        done
    done
done

# to generate shuffling results
for bin_size in 3; do
    for time_range in 3; do
        for areaid in 1 2 3 6; do
            for arg in 200; do
             # Run MATLAB script with argument, load_data from is the last argument 1: striatum, 2: m1, 3: pfc 4:striatum_D1 5:striatum_D2 6:dls
              ~/matlab_no_compile_submit_exclusive_change_dir.sh -t 22 -m 8 -d "/u/home/s/singlade/VLSE_neuro/population_movement_decoding" -f "svm_limb_move_classification_main_hoffman $arg 1 $areaid 1 $bin_size $time_range"
                sleep 2s
            done
        done
    done
done