% Naive Bayes algorithm based classification
function [pred_labels_train, pred_labels_test, modMean]= ...
                                        Poiss_naive_bayes(X_train_str,...
                                            X_test_str,...
                                            ntrials_fixed,total_bins,...
                                            leave_Nout_and_train)

modMean = squeeze(mean(reshape(X_train_str,[size(X_train_str,1),...
                    ntrials_fixed-leave_Nout_and_train,total_bins]),2));
% get training score
logP = zeros((ntrials_fixed-leave_Nout_and_train)*total_bins,total_bins);
logP_test = zeros(leave_Nout_and_train*total_bins,total_bins);
for classIX = 1:total_bins
    currLambda = modMean(:,classIX);
    currLambda = currLambda + 1e-5;
    logP(:,classIX) = sum(currLambda) - X_train_str'*log(currLambda);

    logP_test(:,classIX) = sum(currLambda) - X_test_str'*log(currLambda);
end
[~,pred_labels_train] = min(logP,[],2);

[~,pred_labels_test] = min(logP_test, [], 2);
end