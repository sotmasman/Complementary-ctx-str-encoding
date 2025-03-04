% This script separates the data for train and test and also calls the
% script for training svm model. It is used for training gait phase related 
% models.
if get_min_trials_all
    ntrials_fixed = min(ntrials_per_unit(:));
elseif get_this_many_trials>0
    ntrials_fixed = get_this_many_trials;
end
total_bins = length(binned_degrees)-1;
leave_Nout_and_train = floor(ntrials_fixed/nreps); % or fix it to 2 or 1.

if strcmp(neurons_to_collate,"all")
    X_data = zeros(n_units_now,ntrials_fixed*total_bins);
    
    temp_nrn_arr = 1:n_units_now;
    for kk = 1:n_units_now
        add_unit_to_limb_train
    end
    Y_data = 1:total_bins;
    Y_data = repelem(Y_data,ntrials_fixed);
    
elseif neurons_to_collate <400
    y_act_labels = zeros(n_nrn_draws,leave_Nout_and_train*...
                                    nreps*total_bins);
    y_pred_str = zeros(size(y_act_labels));
    
    for nnrep = start_nrnRep:end_nrnRep
    X_data = zeros(neurons_to_collate,ntrials_fixed*total_bins);
    Y_data = zeros(ntrials_fixed*total_bins,1);
    
    rng(nnrep)
    temp_nrn_arr = randperm(n_units_now);
    temp_nrn_arr = temp_nrn_arr(1:neurons_to_collate);
    for kk = 1:neurons_to_collate
        add_unit_to_limb_train
    end
    Y_data = 1:total_bins;
    Y_data = repelem(Y_data,ntrials_fixed);
    
    % training of the network for this run
    leave_Nout_and_phasetrain_multiDraws_v2
    
    y_act_labels(nnrep,:) = Yall_actual_reps;
    y_pred_str(nnrep,:) = Yall_pred_reps;
    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    disp(' ');
    disp(['Neuron draw number: ', num2str(nnrep), ' is done.']);
    disp(' ');
    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    % 
    end
% else
end