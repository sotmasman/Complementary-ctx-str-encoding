% This file is used for adding unit activity aligned to time near start and
% stop of movement. 
nrn_id = temp_nrn_arr(kk);
this_trials = ntrials_per_unit(nrn_id);
if this_trials>ntrials_fixed
    temp_trl_arr = randperm(this_trials);
    temp_trl_arr = temp_trl_arr(1:ntrials_fixed);
    this_unit_str_rates = unit_wise_walk_fRates{nrn_id,1};
    this_unit_stp_rates = unit_wise_walk_fRates{nrn_id,2};
    if (get_time_in == 1)
        this_unit_str_rates = [this_unit_str_rates(:,1),(this_unit_str_rates(:,2:end) + ...
                                this_unit_str_rates(:,1:(end-1)))/2];
        this_unit_stp_rates = [this_unit_stp_rates(:,1),(this_unit_stp_rates(:,2:end) + ...
                                this_unit_stp_rates(:,1:(end-1)))/2];
    end
    
    X_str_data(kk,:) = reshape(this_unit_str_rates(temp_trl_arr,:),...
                        [ntrials_fixed*total_bins,1]);
    X_stp_data(kk,:) = reshape(this_unit_stp_rates(temp_trl_arr,:),...
                        [ntrials_fixed*total_bins,1]);
    
else

    this_unit_str_rates = unit_wise_walk_fRates{nrn_id,1};
    this_unit_stp_rates = unit_wise_walk_fRates{nrn_id,2};

    if (get_time_in == 1)
        this_unit_str_rates = [this_unit_str_rates(:,1),(this_unit_str_rates(:,2:end) + ...
                                this_unit_str_rates(:,1:(end-1)))/2];
        this_unit_stp_rates = [this_unit_stp_rates(:,1),(this_unit_stp_rates(:,2:end) + ...
                                this_unit_stp_rates(:,1:(end-1)))/2];
    end
    
    X_str_data(kk,:) = reshape(this_unit_str_rates,...
                        [ntrials_fixed*total_bins,1]);
    X_stp_data(kk,:) = reshape(this_unit_stp_rates,...
                        [ntrials_fixed*total_bins,1]);
end
