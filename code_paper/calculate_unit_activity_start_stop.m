% This file calculates the unit activity near start of movement and saves
% all the trials from all sessions into a single data structure. 

for fr_moving_windowsize = fr_moving_windowsize_all
    if smooth_kern == "gaussian"
        kernelSD=fr_moving_windowsize;

        gausskernel=fspecial('gaussian', [1 10*kernelSD], kernelSD);
    end

    
    unit_wise_walk_fRates = {};
    speed_Data_all_ses = cell(n_ses,2); % 1: start, 2: stop
    phase_Data_all_ses = cell(n_ses,2); % 1: start, 2: stop
    n_units_now = 0;
    ntrials_per_unit = [];
    sesid_per_unit = [];
    extra_time = bin_size_val;
    for i = 1:n_ses
        
        speed_Data_str = [];
        speed_Data_stp = [];
        
        phase_Data_str = cell(1,4);
        phase_Data_stp = cell(1,4);

        this_ephys = ephys_all_ses{i};
        this_dounits = unitIDs_all_ses{i};
        this_walks  = walk_prd_for_decd_all_ses{i};
        if exist('rms_speed_all_ses','var')
            this_rms_vel = rms_speed_all_ses{i};
            this_ses_phase = limb_phase_all_ses{i};
        end
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
                
                
            
            else
                during_walk_bins = (this_walks.startframes(jj)/framerate):...
                        (ndur_all(jj)/(framerate*(nbins_for_decd))):(this_walks.stopframes(jj)/framerate);
                before_walk_bins = (this_walks.startframes(jj)/framerate - sep_bw_walk):...
                                    bin_size_val:(this_walks.startframes(jj)/framerate);
                after_walk_bins = (this_walks.stopframes(jj)/framerate):bin_size_val:...
                                    (this_walks.stopframes(jj)/framerate + sep_bw_walk);
            end
        
        end

    bins_walk_spks = 0:bin_size_spks:(120*60); % 120 means 120 minutes
    for ind = 1:length(this_dounits)
        unit_Data_str = [];
        unit_Data_stp = [];
        sub_walk = 0;
        

        n_units_now = n_units_now + 1;
        unitj = this_dounits(ind);
            
        spikeinds_unitj = find(this_ephys.spikeCluster==unitj);
       
        stimesi=this_ephys.spikeTimes(spikeinds_unitj);
        
        if n_units_now == neuron_to_plt
            figure(8)
            clf(8)
            plotraster_gait(this_walks.startframes/framerate, ...
                stimesi, -classify_time_before, ...
                    classify_time_before, 'dots');
            set(gcf,'Position',[scrsz(1)+500 0.4*scrsz(2)+50 ...
                        0.2*scrsz(3) 0.3*scrsz(4)])   

        end
        
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

    % also put speeds and phase angles into bins 
        if exist('rms_speed_all_ses','var')
            calculate_binned_speed
            calculate_binned_phase
        
            speed_Data_all_ses{i,1} = speed_Data_str;
            speed_Data_all_ses{i,2} = speed_Data_stp;
            
            phase_Data_all_ses{i,1} = phase_Data_str;
            phase_Data_all_ses{i,2} = phase_Data_stp;
        end
    end

end