% It calculates decoding accuracies near time to start for all the areas
% separately and also generates the confusion matrices in the figure. 
% Plots figure 2 b and c of the manuscript.
clear all;
close all;
clc;
nnrns = [25,50,100,150,200]; 
brainArea = {'Mpfc','M1','Dms','Dls'};

colormaps = [0,0,0;
             1,0,0;
             0,0,1;
             1,0,1];
binsize = 0.2;
time_range = 1.5;
lineWeight = 0.5;
mkSize = 9;
fontSizeNew = 7;
do_bin_shuf = 0;
bin_shuf_fold = ['bin_',num2str(binsize),...
                    '_time_range_',num2str(time_range)];
kk = 1;
nreps = 50;
qt_val = 95;
include_sem_fac = 1; % for plotting 95% confidence interval
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

% change the uniq_id to pick results from a new folder. 
uniq_id = 'Feb20/'; 
figure(1)
clf(1)
nosqr = 1;
for jj = 1:length(brainArea)
    for ii = nnrns
    
    filename = fullfile(fullfile('../data/svm_start_results/',...
        fullfile([brainArea{jj},'_results_',uniq_id],bin_shuf_fold,'gaussian')),...
        [num2str(ii),'_nrns']);
    if exist(filename,'dir')
    filename = fullfile( filename,'all_plot_data.mat');
    load(filename)
    else
    error('folder does not exist')
    end
    
    max_start_vl(kk,:) = max(start_accrs(:,st_ind:end_ind),[],2);

    if ii == nnrns(end)
    
    % get bin shuffle data
    filename = fullfile(fullfile('../data/svm_start_results/',...
        fullfile([brainArea{jj},'_results_',uniq_id],bin_shuf_fold,'bin_shuffle/gaussian')),...
        [num2str(ii),'_nrns']);
    if exist(filename,'dir')
    filename = fullfile( filename,'all_plot_data.mat');
    bin_shuf_dat = load(filename);
    else
           error('folder does not exist')
    end
    

    %%%%%%%%%%
    start_areaWise{jj} = start_accrs;
    confMatAll_str{jj} = confMat_str;
    subplot(1,length(brainArea),jj)

    mean_val = mean(start_accrs);
    qt_level_up = get_dstr_based_CI(start_accrs,qt_val);
    qt_level_up = qt_level_up - mean_val' ;
    qt_level_down = get_dstr_based_CI(start_accrs,100 - qt_val);
    qt_level_down = mean_val' - qt_level_down;
    SDstartaccr = std(start_accrs,[],1); % standard deviation is used for plotting shaded region
    
    
    mean_bin_shuf_val = mean(bin_shuf_dat.start_accrs);
    SD_bin_shuf_val = std(bin_shuf_dat.start_accrs,[],1);
    qt_bin_shuf = get_dstr_based_CI(bin_shuf_dat.start_accrs,qt_val);

    [ll,~] = boundedline(xaxis_analysis,...
            mean_val, SDstartaccr,...
            'cmap', colormaps(1,:),'alpha');

    set(ll,'linewidth',lineWeight);
    hold on

    plot(xaxis_analysis,qt_bin_shuf, ...
                '--','color',colormaps(4,:),...
                'linewidth',lineWeight);
    ll_all = [ll_all,ll];
    hold on
    title(brainArea{jj});

    xaxis_plt = -1.2:0.4:1.2;
    ylim_all = 0.63;

    ylim([0,ylim_all])
    xlim([xaxis_analysis(1),xaxis_analysis(end)+0.2])
    xlabel('time to start (s)')
    ylabel('decoding accuracy')
    set(gca, 'xtick',xaxis_plt,'YTick',0:0.2:ylim_all);   
    SetFigBoxDefaults
    end
    kk = kk+1;
    end
end
 
set(gcf,'Position',[680 578 1156 230])   

figure(2)
clf(2)
for jj=1:length(brainArea)
    subplot(1,4,jj);
    make_confusion_img(confMatAll_str{jj},'start',xaxis_analysis);
    title(brainArea{jj});
    SetFigBoxDefaults

end
set(gcf,'Position',[166 277 1299 332])