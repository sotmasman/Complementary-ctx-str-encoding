% This script finds out the cumulative distribution from the data. 
function cdf_dstr = get_cdf_ros(xaxis, sorted_dstr)
    % sorted_dstr = sort(dstr);

    all_nos = 0;
    cdf_dstr = [];
    for ii = xaxis
        places = find((sorted_dstr-ii)<=0);
        all_nos = all_nos + length(places);
        cdf_dstr = [cdf_dstr,all_nos];
        sorted_dstr(places) = [];
    end
    cdf_dstr = cdf_dstr/cdf_dstr(end);
end