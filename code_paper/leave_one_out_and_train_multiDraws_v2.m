% this model is used to train the time to movement onset. 
% Multiple cores is used for training. 

plot_test_conf = 0;
nworkers = 40;
hyper_param_opt = {'BoxConstraint','KernelScale'};
max_eval_opt = 20;
temp_select_trials_out = randperm(ntrials_fixed);
temp_select_trials_out = temp_select_trials_out(1:nreps);
nall_wid = total_bins*ntrials_fixed;
Yall_actual_reps = zeros(1,total_bins*nreps);
Yall_pred_reps_str = zeros(1,total_bins*nreps);
Yall_pred_reps_stp = zeros(1,total_bins*nreps);
hypbest_str = table(nreps,2);
hypbest_stp = table(nreps,2);
% create a fixed randomly permuted data array and then use it later for bin
% shuffle case
randperms_X = zeros(nreps,(ntrials_fixed-1)*total_bins);
for repid = 1:nreps
    
    lk = [];
    last_max = 0;
    for mmp = 1:(ntrials_fixed-1)
        mk = randperm(total_bins);
        mk = mk + last_max;
        lk = [lk;mk];
        last_max = mmp*total_bins;
    end
    lk = reshape(lk,...
                 [(ntrials_fixed-1)*total_bins,1]);
    % randperms_X(repid,:) = randperm((ntrials_fixed-1)*total_bins);
    randperms_X(repid,:) = lk;

end
parfor (repid = 1:nreps,nworkers)
    select_outid = temp_select_trials_out(repid);
    selected_out_arr = select_outid:ntrials_fixed:nall_wid;
    allbig_arr = 1:nall_wid;
    allbig_arr(selected_out_arr) = [];
    % training for start 
    X_test_str = X_str_data(:,selected_out_arr);
    X_train_str = X_str_data(:,allbig_arr);
    Y_test_str = Y_str_data(selected_out_arr);
    place_here = ((repid-1)*total_bins + 1):repid*total_bins;
    

    Y_train_str = Y_str_data(allbig_arr);

    if strcmp(shuffle_type, "bin_shuffle")
        
        X_train_str = X_train_str(:,randperms_X(repid,:));
    elseif strcmp(shuffle_type, "activity_shuffle")
        
    end
    if svmtrain==1
    t = templateSVM('Standardize',true,'KernelFunction',char(svm_kern));

    %%%%%%%%%%%%%%%%
    this_perm_det = randperm(length(Y_train_str));

    X_train_str = X_train_str(:,this_perm_det);
    Y_train_str = Y_train_str(this_perm_det);

    %%%%%%%%%%%%%%%%%%%%%%%
    % calculate_bayes_opt_svm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Mdl_str = fitcecoc(X_train_str',Y_train_str,'Learners',t,...
            'OptimizeHyperparameters',hyper_param_opt,...
    'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
    'expected-improvement-plus','UseParallel',false,'ShowPlots',0,...
    'MaxObjectiveEvaluations', max_eval_opt));

    this_best = bestPoint(Mdl_str.HyperparameterOptimizationResults);
    hypbest_str(repid,:) = this_best;
    else
    [~,oofLabelstr,~] =  Poiss_naive_bayes(X_train_str,X_test_str,...
                                ntrials_fixed,total_bins,1);
    
    end
    % oofLabelstr =  Poiss_naive_bayes(X_train_str,ntrials_fixed,total_bins);

    % training for stop
    X_test_stp = X_stp_data(:,selected_out_arr);
    X_train_stp = X_stp_data(:,allbig_arr);
    Y_test_stp = Y_stp_data(selected_out_arr);
    Y_train_stp = Y_stp_data(allbig_arr);
    if strcmp(shuffle_type, "bin_shuffle")
        
        X_train_stp = X_train_stp(:,randperms_X(repid,:));
    elseif strcmp(shuffle_type, "activity_shuffle")
    
    end
    if svmtrain == 1
    t = templateSVM('Standardize',true, 'KernelFunction',char(svm_kern));
    this_perm_det = randperm(length(Y_train_stp));
    X_train_stp = X_train_stp(:,this_perm_det);
    Y_train_stp = Y_train_stp(this_perm_det);
    Mdl_stp = fitcecoc(X_train_stp',Y_train_stp,'Learners',t,...
            'OptimizeHyperparameters',hyper_param_opt,...
    'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
    'expected-improvement-plus','UseParallel',false,'ShowPlots',0,...
    'MaxObjectiveEvaluations', max_eval_opt));
    % oofLabelstp = predict(Mdl_stp,X_test_stp');
    this_best = bestPoint(Mdl_stp.HyperparameterOptimizationResults);
    hypbest_stp(repid,:) = this_best;
    else
    % oofLabelstp = Poiss_naive_bayes(X_train_stp,ntrials_fixed,total_bins);
    [~,oofLabelstp,~] =  Poiss_naive_bayes(X_train_stp,X_test_stp,...
                                ntrials_fixed,total_bins,1);
    end

end

for repid = 1:nreps
    select_outid = temp_select_trials_out(repid);
    selected_out_arr = select_outid:ntrials_fixed:nall_wid;
    allbig_arr = 1:nall_wid;
    allbig_arr(selected_out_arr) = [];
    % training for start 
    X_test_str = X_str_data(:,selected_out_arr);
    X_train_str = X_str_data(:,allbig_arr);
    Y_test_str = Y_str_data(selected_out_arr);
    place_here = ((repid-1)*total_bins + 1):repid*total_bins;
    Yall_actual_reps(:,place_here) = Y_test_str;

    Y_train_str = Y_str_data(allbig_arr);
    if strcmp(shuffle_type, "bin_shuffle")
        
        X_train_str = X_train_str(:,randperms_X(repid,:));
    end
    if svmtrain==1
        bxct = table2array(hypbest_str(repid,1));
        kscl = table2array(hypbest_str(repid,2));
        t = templateSVM('Standardize',true,'KernelFunction',char(svm_kern),...
                'BoxConstraint',bxct, 'KernelScale',kscl);

        this_perm_det = randperm(length(Y_train_str));
    
        X_train_str = X_train_str(:,this_perm_det);
        Y_train_str = Y_train_str(this_perm_det);

        Mdl_str = fitcecoc(X_train_str',Y_train_str,'Learners',t,...
                'Coding','onevsone');
        oofLabelstr = predict(Mdl_str,X_test_str');
    else
    [~,oofLabelstr,~] =  Poiss_naive_bayes(X_train_str,X_test_str,...
                                ntrials_fixed,total_bins,1);
    end
    Yall_pred_reps_str(:,place_here) = oofLabelstr';

    X_test_stp = X_stp_data(:,selected_out_arr);
    X_train_stp = X_stp_data(:,allbig_arr);
    Y_test_stp = Y_stp_data(selected_out_arr);
    Y_train_stp = Y_stp_data(allbig_arr);
    if strcmp(shuffle_type, "bin_shuffle")
        
        X_train_stp = X_train_stp(:,randperms_X(repid,:));
    elseif strcmp(shuffle_type, "activity_shuffle")

    end
    if svmtrain == 1
        bxct = table2array(hypbest_stp(repid,1));
        kscl = table2array(hypbest_stp(repid,2));
        t = templateSVM('Standardize',true,'KernelFunction',char(svm_kern),...
                'BoxConstraint',bxct, 'KernelScale',kscl);
        this_perm_det = randperm(length(Y_train_stp));
        X_train_stp = X_train_stp(:,this_perm_det);
        Y_train_stp = Y_train_stp(this_perm_det);
        Mdl_stp = fitcecoc(X_train_stp',Y_train_stp,'Learners',t,...
                'Coding','onevsone');
        oofLabelstp = predict(Mdl_stp,X_test_stp');
        
    else
    % oofLabelstp = Poiss_naive_bayes(X_train_stp,ntrials_fixed,total_bins);
        [~,oofLabelstp,~] =  Poiss_naive_bayes(X_train_stp,X_test_stp,...
                                ntrials_fixed,total_bins,1);
    end

    Yall_pred_reps_stp(:,place_here) = oofLabelstp';

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
xlabel('time (s)')
ylabel('Accuracy')
title(['Stop']); 
SetFigBoxDefaults
end
