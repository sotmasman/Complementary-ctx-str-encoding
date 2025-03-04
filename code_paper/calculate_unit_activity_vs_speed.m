% This script aligns the unit activity of all the neurons to speed bins and
% puts it in a data structure. 

for fr_moving_windowsize = fr_moving_windowsize_all
    if smooth_kern == "gaussian"
        kernelSD=fr_moving_windowsize;

        gausskernel=fspecial('gaussian', [1 10*kernelSD], kernelSD);
    end

    
    unit_wise_walk_fRates = {};
    mean_spk_speed_data = {};
    SEM_spk_speed_data = {};
    n_units_now = 0;
    ntrials_per_unit = [];
    sesid_per_unit = [];
    extra_time = bin_size_val;
    ntrials_per_unit = [];
    speed_dist = [];
    for i = use_ses
        this_ephys = ephys_all_ses{i};
        this_dounits = unitIDs_all_ses{i};
        this_walks  = walk_prd_for_decd_all_ses{i};
        this_rms_vel = rms_speed_all_ses{i};
        this_stride_frames = strideframes_isct_bouts_all_ses{i};
                n_walks = length(this_walks.startframes);
        ndur_all = this_walks.stopframes - this_walks.startframes;
        frames_walk_wise = []; % the index 1 will contain the bins near start time
        % the index 2 will contain bins near stop time
        for jj = 1:n_walks
            
            during_walk_frames = (this_walks.startframes(jj)):...
                        (this_walks.stopframes(jj));
            frames_walk_wise = [frames_walk_wise,during_walk_frames];
        end
        bins_walk_spks = 0:bin_size_spks:(70*60);
        tmp_rm  = rem(length(this_rms_vel),(bin_size_val*framerate));
       
        if tmp_rm>0
                body_speed_str = mean(reshape(padarray(this_rms_vel,...
                            (bin_size_val*framerate) - tmp_rm,...
                            0,'post'),...
                            uint16(bin_size_val*framerate),[],...
                            size(this_rms_vel,2)),...
                            1);
        else
            body_speed_str = mean(reshape(this_rms_vel,...
                        uint16(bin_size_val*framerate),[],...
                        size(this_rms_vel,2)),...
                        1);
        end
        body_speed_str = squeeze(body_speed_str);

        decm_std_frames = ceil(frames_walk_wise/...
                                    (bin_size_val*framerate));
        decm_std_frames = unique(decm_std_frames);  

        for ind = 1:length(this_dounits)
            n_units_now = n_units_now + 1;
            unitj = this_dounits(ind);
    % 
            spikeinds_unitj = find(this_ephys.spikeCluster==unitj);
    % 
            stimesi=this_ephys.spikeTimes(spikeinds_unitj);

            binned_arr_times = histcounts(stimesi,bins_walk_spks)/bin_size_spks;
            binned_arr_times = smoothdata(binned_arr_times, ...
                                            "gaussian", ...
                                            fr_moving_windowsize);
            
            binned_arr_times = mean(reshape(binned_arr_times,...
                                    uint16(bin_size_val/bin_size_spks),[]));
            
            spk_rates_ph = binned_arr_times(decm_std_frames);
            [this_nspeed, ~,binIDs] = histcounts(...
                                    body_speed_str(decm_std_frames),...
                                                speed_bin_edges);
            tmp_mean = [];
            tmp_SEM  = [];
            % get the rate of spiking activity per speed bin. 
            for kk = 1:(length(speed_bin_edges)-1)
                this_speedinds = find(binIDs==kk);
                tmp_rates_spks = spk_rates_ph(this_speedinds);
                tmp_mean = [tmp_mean,mean(tmp_rates_spks)];
                tmp_SEM = [tmp_SEM, std(tmp_rates_spks)/sqrt(this_nspeed(kk))];
            end
            mean_spk_speed_data{n_units_now} = tmp_mean;
            SEM_spk_speed_data{n_units_now} = tmp_SEM;
            %
            min_per_speed = min(this_nspeed);
            spk_speed_data = zeros(length(speed_bin_edges)-1,min_per_speed);

            for kk = 1:(length(speed_bin_edges)-1)
                this_speedinds = find(binIDs==kk);
                rand_select = randsample(this_nspeed(kk),...
                                    min_per_speed);
                spk_speed_data(kk,:) = spk_rates_ph(this_speedinds(rand_select));
            end 
            unit_wise_fRates{n_units_now} = spk_speed_data;
            ntrials_per_unit = [ntrials_per_unit;min_per_speed];
            sesid_per_unit = [sesid_per_unit, i];
        end

    end

end