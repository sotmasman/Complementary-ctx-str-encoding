For this work, we used Hoffman2 cluster at UCLA (https://www.hoffman2.idre.ucla.edu/) for majority of the analysis. Please use the computing resources at your institution to run scripts related to SVM classification. 
We provide both ways of SVM decoding: predictions from testing (stored in `data` folder) or the scripts provided in `code` folder can be used for training new models  on a computing cluster and generating new predictions. 
Please move the `data` into the `code` folder before proceeding with generating the graphs.

The code requires additional functions from the following links. Please add these functions in the Matlab path. 
1. Tools by Anne Urai: https://github.com/anne-urai/Tools
2. Circular Statistics Toolbox for Matlab: https://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox-directional-statistics

For plotting figure 1f, please follow the procedure below:
- Go to the script `calculate_latency_main.m` in code_paper folder. Change the variable `uniq_id` to save data in a new folder. This variable is a string and it is concatenated to the final folder name. For example, if `uniq_id = 'Feb5'`, the results for M1 will be saved at `'../latency_results/M1_results_Feb5_bsl_0.8_binSize_0.1'`. Run the script for all the four regions by changing `load_data_id`. 
	- For DMS, `load_data_id = 1`
	- For M1, `load_data_id = 2`
	- For mPFC, `load_data_id = 3`
	- For DLS, `load_data_id = 6`.
- Go to the script `plot_figure1f.m` and change `uniq_id` to what you defined in the previous script and run it to generate plots. You can also generate the figures based on previously stored results in `latency_results`.

For plotting figure 2, please follow the procedure below: 
- Go to the script `svm_limb_move_classification_main_hoffman.m` and run it on a cluster with a good amount of cores. It is a function and requires multiple parameters: 
	- `neurons_to_collate`: # of neurons that you want to input for decoding. It can be '200', '100', ....
	- `svmtrain`: If you want to train a svm model, put '1' else '0'.
	- `load_data_id`: same as earlier, put it in a string. 
	- `do_binshuf`: if you want to apply bin shuffling and generate chance accuracies.
	- `bin_size_val`: keep it '3'
	- `classify_time_before`: keep it '3'.
- We also provide a script that you can modify according to your own cluster, `run_svm_start_results.sh`. This script will generate all the required SVM models. 
- Change the variable `uniq_id` to save data in a new folder. This variable is a string and it is concatenated to the final folder name. For example, if `uniq_id = 'Feb20'`, the results for M1 will be saved at `'../svm_start_results/M1_results_Feb20'`. 
- Go to the script `plot_figure2b_c.m` and change `uniq_id` to what you defined in the previous script and run it to generate plots. You can also generate the figures based on previously stored results in `svm_start_results`.
- Go to the script `plot_figure2d.m` and change `uniq_id` to what you defined in the previous script and run it to generate plots. You can also generate the figures based on previously stored results in `svm_start_results`.

For plotting supplementary figure 1, use the following scripts in a similar manner: `plot_suppFigure1a_b.m`, `plot_suppFigure1c.m` and `plot_suppFigure1d.m`.

For plotting figure 3, please follow the procedure below: 
- Go to the script `svm_speed_classification_main_hoffman.m` and run it on a cluster with a good amount of cores. It is a function and requires multiple parameters: 
	- `neurons_to_collate`: # of neurons that you want to input for decoding. Fix it to '100'.
	- `svmtrain`: If you want to train a svm model, put '1' else '0'.
	- `load_data_id`: same as earlier, put it in a string. 
	- `do_binshuf`: if you want to apply bin shuffling and generate chance accuracies, keep it '1' else '0'.
	- `splits`: It generates results for `50/splits` per run. We recommend keeping it `'5'`.
	- `iters`: This parameter should be moved from `1` to `splits` i.e. if `splits=5`, there should be 5 runs in total and this parameter should be changed from `1` to `5`.
- We also provide a script that you can modify according to your own cluster, `run_svm_speed_results.sh`. This script will generate all the required SVM models. 
- Change the variable `uniq_id` to save data in a new folder. This variable is a string and it is concatenated to the final folder name. For example, if `uniq_id = 'Dec7'`, the results for M1 will be saved at `'../svm_speed_results/M1_results_Dec7'`. 
- Go to the script `plot_figure3d_e_f.m` and change `uniq_id` to what you defined in the previous script and run it to generate plots. You can also generate the figures based on previously stored results in `svm_speed_results`.

For plotting figure 6, please follow the procedure below: 
- Go to the script `svm_phase_classification_main_hoffman.m` and run it on a cluster with a good amount of cores. It is a function and requires multiple parameters: 
	- `neurons_to_collate`: # of neurons that you want to input for decoding. Fix it to '200'.
	- `svmtrain`: If you want to train a svm model, put '1' else '0'.
	- `load_data_id`: same as earlier, put it in a string. 
	- `limbid_select`: 1: LF, 2: LR, 3: RF, 4: RR. Change it from `'1'` to `'4'` to train models specific to a limb.
	- `phase_binSize`: Select a bin size for the phase. The classifier then uses `360/phase_binSize` for training the models. Keep it `'30'`.
	- `do_binshuf`: if you want to apply bin shuffling and generate chance accuracies, keep it '1' else '0'.
	- `splits`: It generates results for `50/splits` per run. We recommend keeping it `'5'`.
	- `iters`: This parameter should be moved from `1` to `splits` i.e. if `splits=5`, there should be 5 runs in total and this parameter should be changed from `1` to `5`.
- We also provide a script that you can modify according to your own cluster, `run_svm_phase_results.sh`. This script will generate all the required SVM models. 
- Change the variable `uniq_id` to save data in a new folder. This variable is a string and it is concatenated to the final folder name. For example, if `uniq_id = 'Aug27'`, the results for M1 will be saved at `'../svm_speed_results/M1_results_Aug27'`. 
- Go to the script `plot_figure6b_c_d_e.m` and change `uniq_id` to what you defined in the previous script and run it to generate plots. You can also generate the figures based on previously stored results in `svm_phase_results`.

**Note:** To generate other figures, please go to the specific `plot_figure<>` files and generate the plots. 
