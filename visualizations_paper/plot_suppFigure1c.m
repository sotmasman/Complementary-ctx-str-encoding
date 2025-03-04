% This file plots the RMSE between predicted and actual time for 
% all the areas separately. 
% Plots Supplementary Figure 1c of the manuscript. 

figure(1)
clf(1)

nnrns = [200]; 
brainArea = {'Mpfc','M1','Dms','Dls'};

colormaps = [0,0,0;
             1,0,0;
             1,0,1];
binsize = 0.2;
time_range = 1.5;
lineWeight = 0.5;
mkSize = 36;
fontSizeNew = 7;
qt_val =05;
bin_shuf_fold = ['bin_',num2str(binsize),...
                    '_time_range_',num2str(time_range)];

% change the uniq_id to pick results from a new folder. 
uniq_id = 'Feb20/'; 
kk = 1;
nreps = 50;
include_sem_fac = 1.96; % for plotting 95% confidence interval
max_start_vl = zeros(length(brainArea)*length(nnrns),nreps);
max_stop_vl = zeros(length(brainArea)*length(nnrns),nreps);
st_ind = floor(15/3);
end_ind = 2*st_ind + 1;
ll_all = [];
mm_all = [];
start_areaWise = {};
confMatAll_str = {};
stop_areaWise = {};
confMatAll_stp = {};
nosqr = 1;
for jj = 1:length(brainArea)
    
    
    filename = fullfile(fullfile('../data/svm_start_results/',...
        fullfile([brainArea{jj},'_results_',uniq_id],bin_shuf_fold,'gaussian')),...
        [num2str(nnrns(1)),'_nrns']);
    if exist(filename,'dir')
    filename = fullfile( filename,'all_plot_data.mat');
    load(filename)
    else
    error('folder does not exist')
    end
    
    % get bin shuffle data
    filename = fullfile(fullfile('../data/svm_start_results/',...
        fullfile([brainArea{jj},'_results_',uniq_id],bin_shuf_fold,'bin_shuffle/gaussian')),...
        [num2str(nnrns(1)),'_nrns']);
    if exist(filename,'dir')
    filename = fullfile( filename,'all_plot_data.mat');
    bin_shuf_dat = load(filename);
    else
           error('folder does not exist')
    end
    
    [str_rmse, stp_rmse] = calculate_loc_model_rmse(y_act_labels, y_pred_str,...
                                y_pred_stp,xaxis_analysis);
    start_areaWise{jj} = str_rmse;
    subplot(1,length(brainArea),jj)

    mean_val = mean(str_rmse);
    SDstartaccr = std(str_rmse,[],1);
    qt_level_up = get_dstr_based_CI(str_rmse,qt_val);
    qt_level_up = qt_level_up - mean_val' ;
    qt_level_down = get_dstr_based_CI(str_rmse,100 - qt_val);
    qt_level_down = mean_val' - qt_level_down;
    %%%%% calculate rmse for bin shuffled data
    [bin_shuf_str_rmse, bin_shuf_stp_rmse] = ...
                calculate_loc_model_rmse(bin_shuf_dat.y_act_labels, ...
                                bin_shuf_dat.y_pred_str,...
                                bin_shuf_dat.y_pred_stp,...
                                bin_shuf_dat.xaxis_analysis);
    mean_bin_shuf_val = mean(bin_shuf_str_rmse);
    SD_bin_shuf_val = std(bin_shuf_str_rmse,[],1);
    qt_bin_shuf = get_dstr_based_CI(bin_shuf_str_rmse,qt_val);


    [ll,~] = boundedline(xaxis_analysis,...
            mean_val, SDstartaccr,...
            'cmap', colormaps(1,:),'alpha');

    set(ll,'linewidth',lineWeight);
    hold on

    plot(xaxis_analysis,qt_bin_shuf, ...
                '--','color',colormaps(3,:),...
                'linewidth',lineWeight);
    ll_all = [ll_all,ll];
    title(brainArea{jj})
    hold on;
    ylim_all = 1.6;
    xaxis_plt = -1.2:0.4:1.2;
    ylim([0,ylim_all])
    xlim([xaxis_analysis(1),xaxis_analysis(end)+0.2])
    xlabel('time to start (s)')
    ylabel('RMSE (s)')
    
    set(gca, 'xtick',xaxis_plt,'ytick',0:0.4:ylim_all);
    SetFigBoxDefaults
    kk = kk+1;
    
end
set(gcf,'Position',[680 578 1156 230])   

