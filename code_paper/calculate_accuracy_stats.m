% This file calculates accuracies near start and stop during the training
% run. 
plot_accr_curves = 1;
start_accrs = [];
stop_accrs = [];
confMat_str = zeros(total_bins,total_bins);
confMat_stp = zeros(total_bins,total_bins);
for nnrep = 1:n_nrn_draws
    
[m_str,order] = confusionmat(y_act_labels(nnrep,:),...
                            y_pred_str(nnrep,:));
cl_wise_accrs = diag(m_str)./sum(m_str,2);
confMat_str = confMat_str + m_str;
start_accrs = [start_accrs;cl_wise_accrs'];
[m_stp,order] = confusionmat(y_act_labels(nnrep,:),...
                            y_pred_stp(nnrep,:));
cl_wise_accrs = diag(m_stp)./sum(m_stp,2);
confMat_stp = confMat_stp + m_stp;
stop_accrs = [stop_accrs;cl_wise_accrs'];
end

if plot_accr_curves == 1
figure(3)
clf(3);
plot_combined_results(@pop_plot_default,...
        'accrStacks', true,...
                    'xaxis_analysis', [1:total_bins]*bin_size_val - (bin_size_val*(total_bins+1)/2),...
                    'startaccrs', start_accrs, ...
                    'stopaccrs', stop_accrs);
set(gcf,'Position',[2000   141   837   394]) 
end
