% Used in training gait phase related models. 
% Multiple cores are used to run the models. 
plot_test_conf = 0;
nworkers = 36;
hyper_param_opt = {'BoxConstraint','KernelScale'};

max_eval_opt = 20;
temp_select_trials_out = randperm(ntrials_fixed);
nall_wid = total_bins*ntrials_fixed;

Yall_actual_reps = [];
Yall_pred_reps = [];

hypbest = table(nreps,2);
randperms_X = zeros(nreps,(ntrials_fixed-leave_Nout_and_train)*total_bins);
for repid = 1:nreps
    randperms_X(repid,:) = randperm((ntrials_fixed-leave_Nout_and_train)*...
                                        total_bins);
end
parfor (repid = 1:nreps,nworkers)
    tmp = ((repid-1)*leave_Nout_and_train+1):...
                                        repid*leave_Nout_and_train;
    select_outids = temp_select_trials_out(tmp);
    selected_out_arr = [];
    for sle = select_outids
    selected_out_arr = [selected_out_arr,...
                    sle:ntrials_fixed:nall_wid];
    end

    allbig_arr = 1:nall_wid;
    allbig_arr(selected_out_arr) = [];
    % training for start 
    X_test = X_data(:,selected_out_arr);
    X_train = X_data(:,allbig_arr);
    Y_test= Y_data(selected_out_arr);
    % Yall_actual_reps = [Yall_actual_reps,Y_test];
    Y_train = Y_data(allbig_arr);

    if strcmp(shuffle_type, "bin_shuffle")
        
        X_train= X_train(:,randperms_X(repid,:));
    elseif strcmp(shuffle_type, "activity_shuffle")
      
    end
    if svmtrain==1
    t = templateSVM('Standardize',true,'KernelFunction',char(svm_kern));
 
    this_perm_det = randperm(length(Y_train));
    X_train = X_train(:,this_perm_det);
    Y_train = Y_train(this_perm_det);
    Mdl_str = fitcecoc(X_train',Y_train,'Learners',t,...
            'OptimizeHyperparameters',hyper_param_opt,...
    'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
    'expected-improvement-plus','UseParallel',false,'ShowPlots',0,...
    'MaxObjectiveEvaluations', max_eval_opt));
    oofLabel = predict(Mdl_str,X_test');
    this_best = bestPoint(Mdl_str.HyperparameterOptimizationResults);
    hypbest(repid,:) = this_best;
    else

    [~,oofLabel,~] =  Poiss_naive_bayes(X_train,X_test,...
                                ntrials_fixed,total_bins,...
                                leave_Nout_and_train);
    
    end


    
end

for repid = 1:nreps
    tmp = ((repid-1)*leave_Nout_and_train+1):...
                                        repid*leave_Nout_and_train;
    select_outids = temp_select_trials_out(tmp);
    selected_out_arr = [];
    for sle = select_outids
    selected_out_arr = [selected_out_arr,...
                    sle:ntrials_fixed:nall_wid];
    end

    allbig_arr = 1:nall_wid;
    allbig_arr(selected_out_arr) = [];
    % training for start 
    X_test = X_data(:,selected_out_arr);
    X_train = X_data(:,allbig_arr);
    Y_test= Y_data(selected_out_arr);
    Yall_actual_reps = [Yall_actual_reps,Y_test];
    Y_train = Y_data(allbig_arr);

    if strcmp(shuffle_type, "bin_shuffle")
        
        X_train= X_train(:,randperms_X(repid,:));
    elseif strcmp(shuffle_type, "activity_shuffle")
      
    end
    if svmtrain==1
    bxct = table2array(hypbest(repid,1));
    kscl = table2array(hypbest(repid,2));
    t = templateSVM('Standardize',true,'KernelFunction',char(svm_kern),...
            'BoxConstraint',bxct, 'KernelScale',kscl);

    this_perm_det = randperm(length(Y_train));
    X_train = X_train(:,this_perm_det);
    Y_train = Y_train(this_perm_det);
    Mdl_str = fitcecoc(X_train',Y_train,'Learners',t,...
                'Coding','onevsone');
    oofLabel = predict(Mdl_str,X_test');
    else

    [~,oofLabel,~] =  Poiss_naive_bayes(X_train,X_test,...
                                ntrials_fixed,total_bins,...
                                leave_Nout_and_train);
    
    end
    Yall_pred_reps = [Yall_pred_reps, oofLabel'];
    
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
