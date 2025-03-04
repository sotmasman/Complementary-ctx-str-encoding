% This script calculates the confidence intervals using the data. qt_val
% can be varied from 0 to 100 and it represents percentile. 
function all_array_qt = get_dstr_based_CI(start_accrs,qt_val)

all_array_qt = zeros(size(start_accrs,2),1);
for ii = 1:size(start_accrs,2)
    this_array = start_accrs(:,ii);
    all_array_qt(ii) = prctile(this_array, qt_val);
end
end