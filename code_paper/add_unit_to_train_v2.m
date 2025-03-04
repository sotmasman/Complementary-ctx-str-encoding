% This file is used for adding unit activity aligned to time near start and
% stop of movement. 
% It also saves the trials for time shifted chance. The training data is
% selected from a different time range around the start of movement. 
nrn_id = temp_nrn_arr(kk);
this_trials = ntrials_per_unit(nrn_id);



if this_trials>ntrials_fixed
    temp_trl_arr = randperm(this_trials);
    temp_trl_arr = temp_trl_arr(1:ntrials_fixed);
    this_unit_str_rates = unit_wise_walk_fRates{nrn_id,1};
    this_unit_stp_rates = unit_wise_walk_fRates{nrn_id,2};

    this_unit_str_shuf_rates = unit_wise_shuf_fRates{nrn_id,1};
    this_unit_stp_shuf_rates = unit_wise_shuf_fRates{nrn_id,2}; 
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
    
    
    for chnc_id = 1:st_chance

        X_str_data_shuf = X_str_data_shufAll{chnc_id};
        X_stp_data_shuf = X_stp_data_shufAll{chnc_id};
        
        this_unit_str_shuf  = this_unit_str_shuf_rates{chnc_id};
        this_unit_stp_shuf  = this_unit_stp_shuf_rates{chnc_id};
         
        X_str_data_shuf(kk,:) = reshape(this_unit_str_shuf(temp_trl_arr,:),...
                        [ntrials_fixed*total_bins,1]);
        X_stp_data_shuf(kk,:) =  reshape(this_unit_stp_shuf(temp_trl_arr,:),...
                        [ntrials_fixed*total_bins,1]);

        X_str_data_shufAll{chnc_id} = X_str_data_shuf;
        X_stp_data_shufAll{chnc_id} = X_stp_data_shuf;
        
    end
else

    this_unit_str_rates = unit_wise_walk_fRates{nrn_id,1};
    this_unit_stp_rates = unit_wise_walk_fRates{nrn_id,2};

    this_unit_str_shuf_rates = unit_wise_shuf_fRates{nrn_id,1};
    this_unit_stp_shuf_rates = unit_wise_shuf_fRates{nrn_id,2}; 
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


    for chnc_id = 1:st_chance

        X_str_data_shuf = X_str_data_shufAll{chnc_id};
        X_stp_data_shuf = X_stp_data_shufAll{chnc_id};
        
        this_unit_str_shuf  = this_unit_str_shuf_rates{chnc_id};
        this_unit_stp_shuf  = this_unit_stp_shuf_rates{chnc_id};
         
        X_str_data_shuf(kk,:) = reshape(this_unit_str_shuf,...
                        [ntrials_fixed*total_bins,1]);
        X_stp_data_shuf(kk,:) =  reshape(this_unit_stp_shuf,...
                        [ntrials_fixed*total_bins,1]);

        X_str_data_shufAll{chnc_id} = X_str_data_shuf;
        X_stp_data_shufAll{chnc_id} = X_stp_data_shuf;
        
    end
end
