% this file calculates the speed decoding accuracies for all the four
% areas. 
% Plots figure 3 d, e and f of the manuscript. 
clear all
close all
clc;

figure(1)
clf(1)
nnrns = [100]; 
brainArea = {'Mpfc','M1','Dms','Dls'};
X = categorical({'mPFC','M1','DMS','DLS'});
X = reordercats(X,{'mPFC','M1','DMS','DLS'});

colormaps = [0,0,0;
             1,0,0;
             1,0,1;
             0,0,1];
add_shuffle = 1;
lineWeight  =0.5;
fontSizeNew = 7;
nosqr = 0;
mkSize = 36;
set(groot,'defaultAxesXTickLabelRotationMode','manual')
qt_val = 95;

% change the uniq_id to pick results from a new folder. 
uniq_id = 'Dec7/'; 

save_for_manscrpt = 1;
kk = 1;
nreps = 50;
include_sem_fac = 1.96; % multiply by this factor to plot 95% confidence interval
max_start_vl = zeros(length(brainArea)*length(nnrns),nreps);
max_stop_vl = zeros(length(brainArea)*length(nnrns),nreps);


area_wise_accrs = cell(length(brainArea),1);
area_wise_rmspeeds = cell(length(brainArea),1);
area_wise_confMats = cell(length(brainArea),1);
avg_speed_accr_all = [];
avg_speed_rmse = [];
figure(1);
clf(1);
cid_wise_scores = {};
ll_all = [];
for jj = 1:length(brainArea)
    for ii = nnrns
    
    filename = fullfile(fullfile('../data/svm_speed_results',...
        [brainArea{jj},'_results_',uniq_id,'/gaussian/']),...
        [num2str(ii),'_nrns/']);
    if exist(filename,'dir')
    allfilenames = dir(fullfile( filename,'*.mat'));
    nsplits = length(allfilenames);
    
    else
        error('Folder not found');
    end
    kk = 1;
    start_Rep = double((nreps/nsplits)*(kk-1) + 1);
    end_Rep = double((nreps/nsplits)*kk);
    this_name = ['all_plot_data_rep_',num2str(start_Rep),...
                '_',num2str(end_Rep),'.mat'];
    fullFilename = fullfile(filename, this_name);
    load(fullFilename)
    % xaxis_analysis = xaxis_analysis;
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
    speed_accrs = [];
    conf_mats_this = zeros(length(xaxis_analysis)-1,length(xaxis_analysis)-1);
    
    for nnrep = 1:nreps
    
        [m_str,order] = confusionmat(all_yact(nnrep,:),...
                                    all_ypred(nnrep,:));
        conf_mats_this = conf_mats_this + m_str;
        cl_wise_accrs = diag(m_str)./sum(m_str,2);
        speed_accrs = [speed_accrs;cl_wise_accrs'];
    
    end

    xaxis_all = (xaxis_analysis(1:(end-1))+xaxis_analysis(2:end))/2;
    

    [speed_rmse, ~] = calculate_loc_model_rmse(all_yact, all_ypred,...
                                all_ypred,xaxis_all);
    area_wise_rmspeeds{jj} = speed_rmse;
    avg_speed_rmse = [avg_speed_rmse,mean(speed_rmse,2)];
    nclass = length(xaxis_all);
    temp_xstring = mean([xaxis_analysis(1:(end-1));...
                    xaxis_analysis(2:end)]);
    tmp_cell2 = string(temp_xstring);

    area_wise_accrs{jj} = speed_accrs;
    area_wise_confMats{jj} = conf_mats_this;
    
    avg_speed_accrs = mean(speed_accrs,2);
    avg_speed_accr_all = [avg_speed_accr_all,avg_speed_accrs];

    mean_val = mean(speed_accrs);
    SDstartaccr = std(speed_accrs,[],1);
    % get distribution based Confidence interval
    qt_level_up = get_dstr_based_CI(speed_accrs,qt_val);
    qt_level_up = qt_level_up - mean_val' ;
    qt_level_down = get_dstr_based_CI(speed_accrs,100 - qt_val);
    qt_level_down = mean_val' - qt_level_down;

    subplot(1,length(brainArea),jj);
    [ll,~] = boundedline(xaxis_all,...
            mean_val, SDstartaccr,...
            'cmap', colormaps(1,:),'alpha');
    % [ll,~] = boundedline(xaxis_all,...
    %         mean_val, [qt_level_down,qt_level_up],...
    %         'cmap', colormaps(1,:),'alpha');
    set(ll,'linewidth',lineWeight);
    ll_all = [ll_all, ll];
    xticks(xaxis_all) % define tick locations explicitly
    xticklabels(tmp_cell2) % define tick labels
    title(string(X(jj)));
    xlabel('body speed (mm/s)')
    ylabel('decoding accuracy')
    set(gca, 'Ylim',[0.1,0.85],'YTick',0.2:0.2:0.8);
    hold on;

    end
end

%%
%% only when you are adding shuffled data
if add_shuffle == 1

for jj = 1:length(brainArea)
    for ii = nnrns

    filename = fullfile(fullfile('../data/svm_speed_results',...
        [brainArea{jj},'_results_',uniq_id,'/bin_shuffle/gaussian/']),...
        [num2str(ii),'_nrns/']);
    if exist(filename,'dir')
    allfilenames = dir(fullfile( filename,'*.mat'));
    nsplits = length(allfilenames);
    
    else
        error('Folder not found.')
    end
    kk = 1;
    start_Rep = double((nreps/nsplits)*(kk-1) + 1);
    end_Rep = double((nreps/nsplits)*kk);
    this_name = ['all_plot_data_rep_',num2str(start_Rep),...
                '_',num2str(end_Rep),'.mat'];
    fullFilename = fullfile(filename, this_name);
    load(fullFilename)
    % xaxis_analysis = xaxis_analysis;
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
    shuffle_speed_accrs = [];
    conf_mats_this = zeros(length(xaxis_analysis)-1,length(xaxis_analysis)-1);
    
    for nnrep = 1:nreps
    
        [m_str,order] = confusionmat(all_yact(nnrep,:),...
                                    all_ypred(nnrep,:));
        conf_mats_this = conf_mats_this + m_str;
        cl_wise_accrs = diag(m_str)./sum(m_str,2);
        shuffle_speed_accrs = [shuffle_speed_accrs;cl_wise_accrs'];
    
    end

    xaxis_all = (xaxis_analysis(1:(end-1))+xaxis_analysis(2:end))/2;
    mean_val = mean(shuffle_speed_accrs);
    SDspeedaccr = std(shuffle_speed_accrs,[],1);
    % get distribution based Confidence interval
    qt_bin_shuf = get_dstr_based_CI(shuffle_speed_accrs,qt_val);
    subplot(1,length(brainArea),jj);
    plot(xaxis_all,qt_bin_shuf, ...
                '--','color',colormaps(3,:),...
                'linewidth',lineWeight);
    
    hold on;

    
    end
    end
    
end
set(gcf,'Position',[123 105 1643 304])   

%%
figure(2)
clf(2)

nclass = length(xaxis_all);
for cid = 1:nclass
    a =[];
    for jj = 1:length(brainArea)
        a = [a,area_wise_accrs{jj}(:,cid)];
        this_area_mean  = mean(area_wise_accrs{jj},2);
    end
    cid_wise_scores{cid,1} = a;    
end
cid_wise_scores{nclass+1,1} = avg_speed_accr_all;
cid_wise_scores{nclass+1,2} = avg_speed_rmse;
tmp_cell2 = string(xaxis_analysis);
tmp_cell2 = tmp_cell2(1:nclass) + "-" + tmp_cell2(2:end);
tmp_cell2 = [tmp_cell2, "average"];


stats_save = {};
mult_comparison_save = {};
for compid = 1:(nclass+2)
    thisReg = {};
    if compid == (nclass+2)
        this_tmp = cid_wise_scores{compid-1,2};
    else
    this_tmp = cid_wise_scores{compid,1};
    end
    this_comp = [];
    for arid = 1:length(brainArea)
        all_area_tmp = this_tmp(:,arid);
        thisReg = [thisReg,repelem({char(X(arid))},1,length(all_area_tmp))];
        this_comp = [this_comp,all_area_tmp'];
    end

    [this_stats, this_multcompare] = do_1way_anova(thisReg,this_comp);
    stats_save{compid} = this_stats;
    mult_comparison_save{compid} = this_multcompare;

    
end

%%
figure(2)
clf(2)

nosqr = 1;
for ptid = (nclass+1):(nclass+2)
    subplot_tr = [ 1,2,ptid-nclass];
    subplot(subplot_tr(1),subplot_tr(2),subplot_tr(3))

    if ptid == (nclass+2)
        meanprestartaccr = mean(cid_wise_scores{ptid-1,2});
        SDprestartaccr = std(cid_wise_scores{ptid-1,2},[],1);
        qt_level_up = get_dstr_based_CI(cid_wise_scores{ptid-1,2},qt_val);
        qt_level_down = get_dstr_based_CI(cid_wise_scores{ptid-1,2},100 - qt_val);
    else
        meanprestartaccr = mean(cid_wise_scores{ptid,1});
        SDprestartaccr = std(cid_wise_scores{ptid,1},[],1);
        qt_level_up = get_dstr_based_CI(cid_wise_scores{ptid,1},qt_val);
        qt_level_down = get_dstr_based_CI(cid_wise_scores{ptid,1},100 - qt_val); 
    end
    xvalues= (1:numel(X));
    
    h = ploterr(xvalues, meanprestartaccr, ...
                    [], SDprestartaccr, ...
                    '.');

    hold on;
    set([h(:)],  'color', colormaps(1, :),...
    'linewidth',lineWeight); % set a nice color for the lines
    % how does the marker look?
    set(h(1), 'markersize', mkSize, 'marker','.',...
        'markeredgecolor',colormaps(1, :));
    ylims_here = get(gca, 'ylim');

    yticks_here = get(gca,'YTick');
    
    set(gca, 'Xlim',[xvalues(1)-0.5,xvalues(end) + 0.5],...
    'XTick',xvalues,...
    'XTickLabel',X)
    ylabel('average speed decoding accuracy');
    local_factr = 0.01;
    if ptid<=nclass
        xlabel([char(tmp_cell2{ptid}),' mm/s']);
    elseif ptid==(nclass+1)
        ylim([0.3, 0.55]);
        yticks(0.3:0.1:0.5)
    elseif ptid == (nclass+2)
        ylim([45, 62]);
        yticks(45:5:60)
        ylabel('average RMSE (mm/s)');
        local_factr = 0.2;
    end
    
    SetFigBoxDefaults
        
    
    mutl_tmp = mult_comparison_save{ptid};
    kk = 1;
    for tid1 = 1:(length(brainArea)-1)
        for tid2 = (tid1+1):length(brainArea)
            
            mysigstar(gca, [tid1 tid2], max(abs(ylims_here)) +kk*local_factr, ...
                mutl_tmp.("P-value")(kk));
            kk = kk +1;
        end
    end

end
set(gcf,'Position',[123 305 850 400])   

