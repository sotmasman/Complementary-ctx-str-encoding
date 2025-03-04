% calculate_binned_phase
% This file bins the gait phase and calculates the average phase for each
% of them to be used in the classifier. 

for jj = 1:n_walks
    this_bins = (this_walks.startframes(jj) - (classify_time_before*framerate)):...
                        (this_walks.startframes(jj)+(classify_time_before*framerate)-1);
    phase_str = this_ses_phase(this_bins,:);
    phase_str = circ_mean(reshape(phase_str,...
                        uint16(bin_size_val*framerate),[],size(phase_str,2)),...
                        [],1);
    phase_str = squeeze(phase_str);
    phase_str = wrapTo2Pi(phase_str);
    for kk = 1:4
    phase_Data_str{kk} = [phase_Data_str{kk};phase_str(:,kk)'];
    end

    this_bins = (this_walks.stopframes(jj) - (classify_time_before*framerate)):...
                        (this_walks.stopframes(jj)+(classify_time_before*framerate)-1);
    diff_in_last = this_bins(end) - length(this_ses_phase);
    if diff_in_last>0

        phase_stp = this_ses_phase(this_bins(1):end,:);
        rep_last = repmat(phase_stp(end,:),diff_in_last,1);
        phase_stp = [phase_stp;rep_last];
    else
        phase_stp = this_ses_phase(this_bins,:);
    end
    
    
    phase_stp = circ_mean(reshape(phase_stp,...
                        uint16(bin_size_val*framerate),[],size(phase_stp,2)),...
                        [],1);
    phase_stp = squeeze(phase_stp);
    phase_stp = wrapTo2Pi(phase_stp);
    for kk = 1:4
    phase_Data_stp{kk} = [phase_Data_stp{kk};phase_stp(:,kk)'];
    end
end