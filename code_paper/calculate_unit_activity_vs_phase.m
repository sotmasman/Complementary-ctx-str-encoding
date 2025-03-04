% This script calculates the unit activity aligned to phase and stores it
% for all units in a single data structure.
for fr_moving_windowsize = fr_moving_windowsize_all
    if smooth_kern == "gaussian"
        kernelSD=fr_moving_windowsize;

        gausskernel=fspecial('gaussian', [1 10*kernelSD], kernelSD);
    end

    unit_wise_walk_fRates = {};
    
    n_units_now = 0;
    ntrials_per_unit = [];
    sesid_per_unit = [];
    extra_time = bin_size_val;
    ntrials_per_unit = [];
    for i = 1:n_ses
        this_ephys = ephys_all_ses{i};
        this_dounits = unitIDs_all_ses{i};
        this_walks  = walk_prd_for_decd_all_ses{i};
        this_rms_vel = rms_speed_all_ses{i};
        this_ses_phase = limb_phase_all_ses{i};
        this_stride_frames = strideframes_isct_bouts_all_ses{i};
        
    bins_walk_spks = 0:bin_size_spks:(40*60);
    
    for ind = 1:length(this_dounits)
        n_units_now = n_units_now + 1;
        unitj = this_dounits(ind);
            
        spikeinds_unitj = find(this_ephys.spikeCluster==unitj);
       
        stimesi=this_ephys.spikeTimes(spikeinds_unitj);
        
        binned_arr_times = histcounts(stimesi,bins_walk_spks)/bin_size_spks;
        binned_arr_times = smoothdata(binned_arr_times, ...
                                            "gaussian", ...
                                            fr_moving_windowsize);
        if rem(length(this_ses_phase),2)==1
            phase_str = circ_mean(reshape(padarray(this_ses_phase,1,0,'post'),...
                        uint16(bin_size_val*framerate),[],...
                        size(this_ses_phase,2)),...
                        [],1);
        else
            phase_str = circ_mean(reshape(this_ses_phase,...
                        uint16(bin_size_val*framerate),[],...
                        size(this_ses_phase,2)),...
                        [],1);
        end
        phase_str = squeeze(phase_str);
        phase_str = wrapTo2Pi(phase_str);
        nlimbs = size(this_ses_phase,2);
        binned_degrees = (0:phase_binSize*pi/180:2*pi) - (phase_binSize*pi/360);
        this_unit_trials = [];
        for jj = 1:nlimbs

            decm_std_frames = ceil(this_stride_frames{jj}/...
                                    (bin_size_val*framerate));
            decm_std_frames = unique(decm_std_frames);
            
            spk_rates_ph = binned_arr_times(decm_std_frames);
            
            [this_nphase_limb, ~,binIDs] = histcounts(phase_str(decm_std_frames,jj),...
                                                binned_degrees(2:end));
            % calculate the points with -(phase_binSize/2) to
            % (phase_binSize/2).
            ftval = wrapTo2Pi(-phase_binSize*pi/360);
            endval = phase_binSize*pi/360;
            [placeids] = find((phase_str(decm_std_frames,jj)>=ftval)|...
                    (phase_str(decm_std_frames,jj)<endval));
            
            min_per_ph = min(this_nphase_limb);
            min_per_ph = min([min_per_ph,length(placeids)]);

            spk_phase_data = zeros(length(binned_degrees)-1,min_per_ph);

            rand_select = randsample(length(placeids),...
                               min_per_ph);
            spk_phase_data(1,:) = spk_rates_ph(placeids(rand_select));
            for kk = 1:(length(binned_degrees)-2)
                this_phinds = find(binIDs==kk);
                rand_select = randsample(this_nphase_limb(kk),...
                                    min_per_ph);
                spk_phase_data(kk+1,:) = spk_rates_ph(this_phinds(rand_select));
            end 
            unit_wise_fRates{n_units_now,jj} = spk_phase_data;
            this_unit_trials = [this_unit_trials,min_per_ph];
            
        end
        
        ntrials_per_unit = [ntrials_per_unit;this_unit_trials];
        sesid_per_unit = [sesid_per_unit, i];
    end    
    end

end