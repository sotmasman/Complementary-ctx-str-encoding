% This script calculates the rmse between predicted and actual time. 
% Used in RMSE analysis in figure 2. 
function [str_rmse, stp_rmse] = calculate_loc_model_rmse(y_act_labels, y_pred_str,...
                                y_pred_stp,xaxis_analysis)

y_pred_str_time = xaxis_analysis(y_pred_str);
y_pred_stp_time = xaxis_analysis(y_pred_stp);
y_act_time = xaxis_analysis(y_act_labels);
nlabels = length(xaxis_analysis);
ntest_reps = size(y_act_labels,2)/nlabels;
nndraws = size(y_act_labels,1);

str_rmse = [];
stp_rmse = [];
for nnrep = 1:nndraws
    temp_act = reshape(y_act_time(nnrep,:),[nlabels,ntest_reps]);
    temp_pred_str = reshape(y_pred_str_time(nnrep,:),...
                        [nlabels,ntest_reps]);
    this_rep_rmse = ...
            sqrt(sum((temp_act - temp_pred_str).^2,2)/ntest_reps);
    str_rmse = [str_rmse;this_rep_rmse'];

    temp_pred_stp = reshape(y_pred_stp_time(nnrep,:),...
                        [nlabels,ntest_reps]);
    this_rep_rmse = ...
            sqrt(sum((temp_act - temp_pred_stp).^2,2)/ntest_reps);
    stp_rmse = [stp_rmse;this_rep_rmse'];
end

end