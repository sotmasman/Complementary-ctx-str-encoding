% this script is used to calculate unit activity near start and stop for
% the latency analysis. 
for fr_moving_windowsize = fr_moving_windowsize_all
    if smooth_kern == "gaussian"
        kernelSD=fr_moving_windowsize;

        gausskernel=fspecial('gaussian', [1 10*kernelSD], kernelSD);
    end

    
    unit_wise_walk_fRates = {};
    unit_wise_Ivals = {};
    speed_Data_all_ses = cell(n_ses,2); % 1: start, 2: stop
    n_units_now = 0;
    ntrials_per_unit = [];
    sesid_per_unit = [];
    extra_time = bin_size_val;
    for i = 1:n_ses
        
        speed_Data_str = [];
        speed_Data_stp = [];

        this_ephys = ephys_all_ses{i};
        this_dounits = unitIDs_all_ses{i};
        % the two lines below are used only for ballMouse.
        % this_walks  = walk_period_all_ses{i};
        % this_rms_vel = angular_vel_all_ses{i};

        this_walks  = walk_prd_for_decd_all_ses{i};
        this_rms_vel = rms_speed_all_ses{i};
        n_walks = length(this_walks.startframes);
        ndur_all = this_walks.stopframes - this_walks.startframes;
        bins_walk_wise = {}; % the index 1 will contain the bins near start time
        % the index 2 will contain bins near stop time
        for jj = 1:n_walks
            if same_binsize
                bins_walk_wise{jj,1} = (this_walks.startframes(jj)/framerate - classify_time_before-extra_time):bin_size_spks:...
                    (this_walks.startframes(jj)/framerate+classify_time_before+extra_time);
                bins_walk_wise{jj,2} = (this_walks.stopframes(jj)/framerate - classify_time_before-extra_time):bin_size_spks:...
                    (this_walks.stopframes(jj)/framerate+classify_time_before+extra_time);
            end
        
        end

    bins_walk_spks = 0:bin_size_spks:(70*60);
    for ind = 1:length(this_dounits)
        unit_Data_str = [];
        unit_Data_stp = [];
        sub_walk = 0;
        

        n_units_now = n_units_now + 1;
        unitj = this_dounits(ind);
            
        spikeinds_unitj = find(this_ephys.spikeCluster==unitj);
       
        stimesi=this_ephys.spikeTimes(spikeinds_unitj);
       
        
        binned_arr_times = histcounts(stimesi,bins_walk_spks)/bin_size_spks;
        binned_arr_times = smoothdata(binned_arr_times, ...
                                            "gaussian", ...
                                            fr_moving_windowsize);
        
        for jj = 1:n_walks
            this_bins = bins_walk_wise{jj,1};
            this_bins = (this_bins(1:(end-1)) + this_bins(2:end))/2;
            str_bins = round(this_bins/bin_size_spks) + 1;
            if ((str_bins(1)>0) && (str_bins(end)<=length(binned_arr_times)))
                spikeratei_str = binned_arr_times(str_bins);
                spikeratei_str = mean(reshape(spikeratei_str,...
                                        uint16(bin_size_val/bin_size_spks),[]));
                spikeratei_str = spikeratei_str(2:(end-1));
                this_bins = bins_walk_wise{jj,2};
                this_bins = (this_bins(1:(end-1)) + this_bins(2:end))/2;
                stp_bins = round(this_bins/bin_size_spks) + 1;
                spikeratei_stp = binned_arr_times(stp_bins);
                spikeratei_stp = mean(reshape(spikeratei_stp,...
                                        uint16(bin_size_val/bin_size_spks),[]));
                spikeratei_stp = spikeratei_stp(2:(end-1));

                unit_Data_str = [unit_Data_str;spikeratei_str];
                unit_Data_stp = [unit_Data_stp;spikeratei_stp];
            else
                sub_walk = sub_walk + 1;    
            end  
            
            
        end
        unit_wise_walk_fRates{n_units_now,1} = unit_Data_str;
        unit_wise_walk_fRates{n_units_now,2} = unit_Data_stp;
        ntrials_per_unit = [ntrials_per_unit,n_walks-sub_walk];        
        sesid_per_unit = [sesid_per_unit, i];
        
        
    end
    if calculate_jitStats == 1
        tot_bins = length(spikeratei_str);
        xaxis_analysis =  [1:tot_bins]*bin_size_val - (bin_size_val*(tot_bins+1)/2);
        unit_wise_this1 = {};
        unit_wise_this2 = {};
        parfor (ind = 1:length(this_dounits),8)
            unitj = this_dounits(ind);
                
            spikeinds_unitj = find(this_ephys.spikeCluster==unitj);
           
            stimesi=this_ephys.spikeTimes(spikeinds_unitj);
            
            [I_val_start,I_val_stop] = calculate_jitter_start_stopI(stimesi,...
                                        bins_walk_wise,...
                                        n_walks,...
                                        bins_walk_spks,bin_size_spks,...
                                        bin_size_val,...
                                        baseline_period,...
                                        xaxis_analysis,...
                                        fr_moving_windowsize,...
                                        max_jittertime, ...
                                        numberofjitters);
            unit_wise_this1{ind,1} = I_val_start;
            unit_wise_this2{ind,1} = I_val_stop;

        end
        unit_wise_Ivals = [unit_wise_Ivals;[unit_wise_this1,unit_wise_this2]];
    end
    % also put speeds and phase angles into bins 
    calculate_binned_speed

    speed_Data_all_ses{i,1} = speed_Data_str;
    speed_Data_all_ses{i,2} = speed_Data_stp;

    end

end