% calculate_binned_speed
% This file bins the body speed and averages it over the binned period. 
for jj = 1:n_walks
    this_bins = (this_walks.startframes(jj) - (classify_time_before*framerate)):...
                        (this_walks.startframes(jj)+(classify_time_before*framerate)-1);
    speed_str = this_rms_vel(this_bins);
    speed_str = mean(reshape(speed_str,...
                        uint16(bin_size_val*framerate),[]));
    speed_Data_str = [speed_Data_str;speed_str];
    
    this_bins = (this_walks.stopframes(jj) - (classify_time_before*framerate)):...
                        (this_walks.stopframes(jj)+(classify_time_before*framerate)-1);
    diff_in_last = this_bins(end) - length(this_rms_vel);
    if diff_in_last>0
        speed_stp = this_rms_vel(this_bins(1):end);
        rep_last = repmat(speed_stp(end),diff_in_last,1);
        speed_stp = [speed_stp;rep_last];
    else
        speed_stp = this_rms_vel(this_bins);
    end
    speed_stp = mean(reshape(speed_stp,...
                        uint16(bin_size_val*framerate),[]));
    speed_Data_stp = [speed_Data_stp;speed_stp];
end