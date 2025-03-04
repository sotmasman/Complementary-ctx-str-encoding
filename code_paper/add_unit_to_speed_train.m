% add_unit_to_speed_train 
% This function is only used in speed decoding. Selects the neuron firing
% for different trials of speed. 
nrn_id = temp_nrn_arr(kk);
this_trials = ntrials_per_unit(nrn_id);
if this_trials>ntrials_fixed
    temp_trl_arr = randperm(this_trials);
    temp_trl_arr = temp_trl_arr(1:ntrials_fixed);
    this_unit_rates = unit_wise_fRates{nrn_id}';
    
    
    X_data(kk,:) = reshape(this_unit_rates(temp_trl_arr,:),...
                        [ntrials_fixed*total_bins,1]);
    
    
else

    this_unit_rates = unit_wise_fRates{nrn_id}';
    
    X_data(kk,:) = reshape(this_unit_rates,...
                        [ntrials_fixed*total_bins,1]);  
end
