% This script separates the data for train and test and also calls the
% script for training svm model. It is used for training time related
% models. 
if get_min_trials_all
    ntrials_fixed = min(ntrials_per_unit);
elseif get_this_many_trials>0
    ntrials_fixed = get_this_many_trials;
end

if strcmp(neurons_to_collate,"all")
    X_str_data = zeros(n_units_now,ntrials_fixed*total_bins);
    Y_str_data = zeros(ntrials_fixed*total_bins,1);
    X_stp_data = zeros(size(X_str_data));
    Y_stp_data = zeros(ntrials_fixed*total_bins,1);
    temp_nrn_arr = 1:n_units_now;
    for kk = 1:n_units_now
        add_unit_to_train
    end
    Y_str_data = 1:total_bins;
    Y_str_data = repelem(Y_str_data,ntrials_fixed);
    Y_stp_data(:) = Y_str_data;
elseif neurons_to_collate <400
    y_act_labels = zeros(n_nrn_draws,nreps*total_bins);
    if shuffle_type == "chance_time_shuffle"
        y_act_labels = zeros(n_nrn_draws,st_chance*total_bins);
    end
    y_pred_str = zeros(size(y_act_labels));
    y_pred_stp = zeros(size(y_act_labels));
    for nnrep = 1:n_nrn_draws
    X_str_data = zeros(neurons_to_collate,ntrials_fixed*total_bins);
    Y_str_data = zeros(ntrials_fixed*total_bins,1);
    X_stp_data = zeros(size(X_str_data));
    Y_stp_data = zeros(ntrials_fixed*total_bins,1);
    temp_nrn_arr = randperm(n_units_now);
    temp_nrn_arr = temp_nrn_arr(1:neurons_to_collate);

    if shuffle_type == "chance_time_shuffle"
    % These two arrays will be used for the shuffled data.
        X_str_data_shufAll = {};
        X_stp_data_shufAll = {};
        
        for chnc_id = 1:st_chance
            X_str_data_shuf = zeros(neurons_to_collate,ntrials_fixed*total_bins);
            X_stp_data_shuf = zeros(size(X_str_data));
            
            X_str_data_shufAll{chnc_id} = X_str_data_shuf;
            X_stp_data_shufAll{chnc_id} = X_stp_data_shuf;
            
        end
    

        for kk = 1:neurons_to_collate
            add_unit_to_train_v2
        end
    else
        for kk = 1:neurons_to_collate
            add_unit_to_train
        end
    end
    Y_str_data = 1:total_bins;
    Y_str_data = repelem(Y_str_data,ntrials_fixed);
    Y_stp_data(:) = Y_str_data;
    
    % training of the network for this run
    if shuffle_type == "chance_time_shuffle"
        leave_one_out_and_time_shift_train
    else
        leave_one_out_and_train_multiDraws_v2
    end
    y_act_labels(nnrep,:) = Yall_actual_reps;
    y_pred_str(nnrep,:) = Yall_pred_reps_str;
    y_pred_stp(nnrep,:) = Yall_pred_reps_stp;

    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    disp(' ');
    disp(['Neuron draw number: ', num2str(nnrep), ' is done.']);
    disp(' ');
    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    
    end

end