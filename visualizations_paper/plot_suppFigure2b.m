% This file plots decoding accuracies averaged over limbs over the different 
% number of units for all the areas.
% Plots Supplementary Figure 2b of the manuscript. 

clear all
close all
clc;
nnrns = [25,50,100,150,200]; % for striatum_D2
brainArea = {'Mpfc','M1','Dms','Dls'};

colormaps = [0,0,0;
             1,0,0;
             0.9290,0.6940,0.1250];

lineWeight  =0.5;
fontSizeNew = 7;
nosqr = 0;
uniq_id = 'Apr20/'; 

set(groot,'defaultAxesXTickLabelRotationMode','manual')

qt_val = 95;
add_shuffle = 0;
repeat_twice = 0;

kk = 1;
nreps = 50;
ci_factor = 1.96; % multiply by this factor to plot 95% confidence interval
max_start_vl = zeros(length(brainArea)*length(nnrns),nreps);
max_stop_vl = zeros(length(brainArea)*length(nnrns),nreps);

ll_all = cell(1,4);

limb_names_order = {'LF','LR','RF','RR'};
limb_select = 1;
limb_wise_accrs = cell(length(brainArea),4,length(nnrns));
for limb_select = 1:4
    ll_this = [];
    for jj = 1:length(brainArea)
    for ii = nnrns
    
    filename = fullfile('../data/svm_phase_results',...
        fullfile([brainArea{jj},'_results_',uniq_id],'gaussian/bin_size_30'),...
        [num2str(ii),'_nrns/',limb_names_order{limb_select},'/']);
    if exist(filename,'dir')
    allfilenames = dir(fullfile( filename,'*.mat'));
    nsplits = length(allfilenames);

    else
        error('Folder not found.')
    end
    [phase_accrs,conf_mats_this,xaxis_analysis] = get_this_phase_accr(filename, ...
                                        nreps, nsplits);
    
    xaxis_all = (xaxis_analysis(1:(end-1))+xaxis_analysis(2:end))/2;

    limb_wise_accrs{jj,limb_select,ii} = phase_accrs;
    end
    end
    ll_all{limb_select} = ll_this;
end


%% get average limb wise accuracies for all areas.
Region = [];
all_area_accrs = [];
stats_save = {};
mult_comparison_save = {};
figure(52);
clf(52);
nosqr =1;
ncombs = length(nnrns);
for kk = 1:length(brainArea)
    area_nrn_accrs = [];
    for ii = nnrns
    this_area_accr = cell2mat(arrayfun(@(c) mean(c{1},2), ...
        limb_wise_accrs(kk,1:length(limb_names_order),ii),...
        'UniformOutput', false));
    this_area_accr = mean(this_area_accr,2); 
    area_nrn_accrs = [area_nrn_accrs,this_area_accr];
    ntr = size(this_area_accr,1);
    end
    
    % calculate the stats
    thisnrn = {};
    this_tmp = area_nrn_accrs;
    this_comp = [];
    for ncnt = 1:ncombs
        all_nrn_tmp = this_tmp(:,ncnt);
        thisnrn = [thisnrn,repelem({char(num2str(ncnt))},1,length(all_nrn_tmp))];
        this_comp = [this_comp,all_nrn_tmp'];
    end
    figure(2)
    clf(2)
    [this_stats, this_multcompare] = do_1way_anova(thisnrn,this_comp);
    stats_save{kk} = this_stats;
    mult_comparison_save{kk} = this_multcompare;
    %%%%%%%%%%%%%%%%%%%%%%

    figure(52)
    subplot(1,length(brainArea),kk);
    meanaccrs = mean(area_nrn_accrs,1);
    stdaccrs = std(area_nrn_accrs,[],1);
    qt_level_up = get_dstr_based_CI(area_nrn_accrs,qt_val);
    qt_level_down = get_dstr_based_CI(area_nrn_accrs,100 - qt_val);

    h = ploterr(nnrns, meanaccrs, ...
            [], stdaccrs, ...
            '-');

    hold on;
    set([h(:)],  'color', colormaps(1, :),...
        'linewidth',lineWeight); 
    % how does the marker look?
    set(h(1), 'markersize', 18, 'marker','.',...
        'markeredgecolor',colormaps(1, :)); % make the marker open

    ylims_here = get(gca, 'ylim');    
    yticks_here = get(gca,'YTick');
    if (kk==1) || (kk==3)
    ylim([0.05,0.2]);
    else
    ylim([min(abs(ylims_here))*0.8,max(abs(ylims_here))*1.1]);
    end
    xlim([0,210]);
    set(gca, 'YTick',0:0.1:0.5,'XTick',0:50:200)
    title(brainArea{kk})
    xlabel('# of units')
    ylabel('limb average decoding accuracy')
    SetFigBoxDefaults
end

set(gcf,'Position',[500 778 1156 350])   


