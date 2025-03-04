% This file finds out the gait phase prediction performance in terms of
% accuracies and mean absolute error. It goes through all the files in the
% results folder since the results are saved in splits. 
function [phase_accrs,conf_mats_this,...
            phase_mad,xaxis_analysis] = get_this_phase_accr(filename, ...
                                        nreps, nsplits)

    kk = 1;
    start_Rep = double((nreps/nsplits)*(kk-1) + 1);
    end_Rep = double((nreps/nsplits)*kk);
    this_name = ['all_plot_data_rep_',num2str(start_Rep),...
                '_',num2str(end_Rep),'.mat'];
    fullFilename = fullfile(filename, this_name);
    load(fullFilename)
    xaxis_analysis = xaxis_analysis;
    all_yact = zeros(size(y_act_labels));
    all_ypred = zeros(size(y_pred_str));
    all_yact = all_yact + y_act_labels;
    all_ypred = all_ypred + y_pred_str;
    for kk=2:nsplits
        start_Rep = double((nreps/nsplits)*(kk-1) + 1);
        end_Rep = double((nreps/nsplits)*kk);
        this_name = ['all_plot_data_rep_',num2str(start_Rep),...
                    '_',num2str(end_Rep),'.mat'];
        fullFilename = fullfile(filename, this_name);
        load(fullFilename)
        all_yact = all_yact + y_act_labels;
        all_ypred = all_ypred + y_pred_str;
    end
    phase_accrs = [];
    conf_mats_this = zeros(length(xaxis_analysis)-1,length(xaxis_analysis)-1);
    max_yact = max(all_yact(:));
    ntest_reps = size(all_yact,2)/max_yact;

    % get Absolute Deviation between the predictions and actual values.
    yact_rad = (all_yact-1)*(2*pi/max_yact);
    ypred_rad = (all_ypred-1)*(2*pi/max_yact);
    abs_deviation = abs(angdiff(yact_rad,ypred_rad));
    phase_mad = [];
    for nnrep = 1:nreps
        temp_act = reshape(abs_deviation(nnrep,:),[max_yact,ntest_reps]);
        
        this_rep_mad = mean(temp_act,2);
        phase_mad = [phase_mad;this_rep_mad'];
 
    end
    phase_mad = phase_mad*180/pi;

    for nnrep = 1:nreps
    
        [m_str,order] = confusionmat(all_yact(nnrep,:),...
                                    all_ypred(nnrep,:));
        conf_mats_this = conf_mats_this + m_str;
        cl_wise_accrs = diag(m_str)./sum(m_str,2);
        phase_accrs = [phase_accrs;cl_wise_accrs'];
    
    end
end