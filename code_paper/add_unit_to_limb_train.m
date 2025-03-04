% add_unit_to_limb_train 
% This function is only used in phase decoding. Selects the neuron firing
% rates for that particular limb. 
nrn_id = temp_nrn_arr(kk);
this_trials = ntrials_per_unit(nrn_id,limbid_select);
if this_trials>ntrials_fixed
    temp_trl_arr = randperm(this_trials);
    temp_trl_arr = temp_trl_arr(1:ntrials_fixed);
    this_unit_rates = unit_wise_fRates{nrn_id,limbid_select}';
    
    
    X_data(kk,:) = reshape(this_unit_rates(temp_trl_arr,:),...
                        [ntrials_fixed*total_bins,1]);
    
    
else

    this_unit_rates = unit_wise_fRates{nrn_id,limbid_select}';
    
    X_data(kk,:) = reshape(this_unit_rates,...
                        [ntrials_fixed*total_bins,1]);  
end
