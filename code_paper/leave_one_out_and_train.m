% this model is used to train the time to movement onset. 
% Single core is used for training. 

plot_test_conf = 1;
temp_select_trials_out = randperm(ntrials_fixed);
temp_select_trials_out = temp_select_trials_out(1:nreps);
nall_wid = total_bins*ntrials_fixed;
Yall_actual_reps = [];
Yall_pred_reps_str = [];
Yall_pred_reps_stp = [];
for repid = 1:nreps
    select_outid = temp_select_trials_out(repid);
    selected_out_arr = select_outid:ntrials_fixed:nall_wid;
    allbig_arr = 1:nall_wid;
    allbig_arr(selected_out_arr) = [];
    % training for start 
    X_test_str = X_str_data(:,selected_out_arr);
    X_train_str = X_str_data(:,allbig_arr);
    Y_test_str = Y_str_data(selected_out_arr);
    Yall_actual_reps = [Yall_actual_reps,Y_test_str];
    Y_train_str = Y_str_data(allbig_arr);
    if svmtrain==1
    t = templateSVM('Standardize',true,'KernelFunction','gaussian');

    this_perm_det = randperm(length(Y_train_str));
    X_train_str = X_train_str(:,this_perm_det);
    Y_train_str = Y_train_str(this_perm_det);
    Mdl_str = fitcecoc(X_train_str',Y_train_str,'Learners',t,...
            'OptimizeHyperparameters','auto',...
    'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
    'expected-improvement-plus','UseParallel',true,'ShowPlots',0));
    oofLabelstr = predict(Mdl_str,X_test_str');

    else
    % options = statset('UseParallel',true);
    % Mdl_str = fitcecoc(X_train_str',Y_train_str,'Coding','onevsone','Learners',t,...
    %             'Options',options);
    [~,oofLabelstr,~] =  Poiss_naive_bayes(X_train_str,X_test_str,...
                                ntrials_fixed,total_bins,1);
    
    end
    Yall_pred_reps_str = [Yall_pred_reps_str, oofLabelstr'];
    % oofLabelstr =  Poiss_naive_bayes(X_train_str,ntrials_fixed,total_bins);

    % training for stop
    X_test_stp = X_stp_data(:,selected_out_arr);
    X_train_stp = X_stp_data(:,allbig_arr);
    Y_test_stp = Y_stp_data(selected_out_arr);
    Y_train_stp = Y_stp_data(allbig_arr);
    if svmtrain == 1
    t = templateSVM('Standardize',true, 'KernelFunction','gaussian');
    this_perm_det = randperm(length(Y_train_stp));
    X_train_stp = X_train_stp(:,this_perm_det);
    Y_train_stp = Y_train_stp(this_perm_det);
    Mdl_stp = fitcecoc(X_train_stp',Y_train_stp,'Learners',t,...
            'OptimizeHyperparameters','auto',...
    'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
    'expected-improvement-plus','UseParallel',true,'ShowPlots',0));
    oofLabelstp = predict(Mdl_stp,X_test_stp');
    else
    % oofLabelstp = Poiss_naive_bayes(X_train_stp,ntrials_fixed,total_bins);
    [~,oofLabelstp,~] =  Poiss_naive_bayes(X_train_stp,X_test_stp,...
                                ntrials_fixed,total_bins,1);
    end
    Yall_pred_reps_stp = [Yall_pred_reps_stp, oofLabelstp'];

    % options = statset('UseParallel',true);
    % Mdl_stp = fitcecoc(X_train_stp',Y_train_stp,'Coding','onevsone','Learners',t,...
    %             'Prior','uniform','Options',options);
end

if plot_test_conf == 1
close all
figure(1)
clf(1)
subplot(2,2,1)

ConfMat = confusionchart(Yall_actual_reps,Yall_pred_reps_str,...
        'RowSummary','total-normalized');
cfmat = ConfMat.NormalizedValues;
cl_wise_accrs = diag(cfmat)./sum(cfmat,2);

subplot(2,2,2)
plot([1:total_bins]*bin_size_val - (bin_size_val*(total_bins+1)/2),...
    cl_wise_accrs)
ylim([0,1])
xlabel('time (s)')
ylabel('Accuracy')
title(['Start']); 
SetFigBoxDefaults

subplot(2,2,3)

ConfMat = confusionchart(Yall_actual_reps,Yall_pred_reps_stp,...
        'RowSummary','total-normalized');
cfmat = ConfMat.NormalizedValues;
cl_wise_accrs = diag(cfmat)./sum(cfmat,2);

subplot(2,2,4)
plot([1:total_bins]*bin_size_val - (bin_size_val*(total_bins+1)/2),...
    cl_wise_accrs)
ylim([0,1])
xlabel('time (s)')
ylabel('Accuracy')
title(['Stop']); 
SetFigBoxDefaults
end
% Y_str_pred = predict(Mdl_str, X_test_str')