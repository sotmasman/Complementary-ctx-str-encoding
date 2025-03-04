% Calculates the significance of modulation based on a jitter test. 

function [I_val_start,I_val_stop] = calculate_jitter_start_stopI(spiketimes,...
                                    bins_walk_wise,...
                                    n_walks,...
                                    bins_walk_spks,bin_size_spks,...
                                    bin_size_val,...
                                    baseline_period,...
                                    xaxis_analysis,...
                                    fr_moving_windowsize,...
                                    max_jittertime, ...
                                    numberofjitters)
    total_bins = length(xaxis_analysis);
    baseline_bins_str = find((xaxis_analysis>=baseline_period(1))& ...
                    (xaxis_analysis<=baseline_period(2)));
    baseline_bins_stp = find((xaxis_analysis>=-baseline_period(2))& ...
                    (xaxis_analysis<=-baseline_period(1)));
    I_val_start = [];
    I_val_stop = [];
    
    for jitterind = 1:numberofjitters
        jittered_spiketimes = spiketimes + ...
            (max_jittertime*rand(length(spiketimes),1)-max_jittertime/2);
        jittered_spiketimes(jittered_spiketimes<=0) = []; 
        binned_arr_times = histcounts(jittered_spiketimes,bins_walk_spks)/bin_size_spks;
        binned_arr_times = smoothdata(binned_arr_times, ...
                                            "gaussian", ...
                                            fr_moving_windowsize);

        unit_Data_str = [];
        unit_Data_stp = [];
        for jj = 1:n_walks
            this_bins = bins_walk_wise{jj,1};
            this_bins = (this_bins(1:(end-1)) + this_bins(2:end))/2;
            str_bins = round(this_bins/bin_size_spks) + 1;
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
       
        end
        tmp1 = unit_Data_str(:,baseline_bins_str);
        tmp1 = mean(tmp1,2);
        
        tmp2 = unit_Data_stp(:,baseline_bins_stp);
        tmp2 = mean(tmp2,2);
        I_val_this = [];
        for ll = baseline_bins_str(1):total_bins
            f_this = unit_Data_str(:,ll);
            f_bsl = tmp1;
            % get mean of firing rates instead

            I_val = mean(f_this-f_bsl)/mean(f_this+f_bsl);

            I_val_this = [I_val_this,I_val];
        end
        I_val_start = [I_val_start;I_val_this];
        I_val_this = [];
        for ll = 1:baseline_bins_stp(end)
            f_this = unit_Data_stp(:,ll);
            f_bsl = tmp2;
            I_val = mean(f_this-f_bsl)/mean(f_this+f_bsl);
            
            I_val_this = [I_val_this,I_val];
        
        end
        I_val_stop = [I_val_stop;I_val_this];
    end
end


        