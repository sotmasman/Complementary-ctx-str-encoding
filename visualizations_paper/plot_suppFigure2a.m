% This file plots the average accuracy per limb for all the four areas.
% Plots Supplementary Figure 2a of the manuscript. 

clear all
close all
clc;
nnrns = [200];
brainArea = {'Mpfc','M1','Dms','Dls'};
X = categorical({'mPFC','M1','DMS','DLS'});
X = reordercats(X,{'mPFC','M1','DMS','DLS'});

colormaps = [0,0,0;
             1,0,0;
             1,0,1];
lineWeight  =0.5;
fontSizeNew = 7;
nosqr = 1;
qt_val = 95;

% change the uniq_id to pick results from a new folder. 
uniq_id = 'Apr20/'; 

set(groot,'defaultAxesXTickLabelRotationMode','manual')

add_shuffle = 1;
repeat_twice = 0;
save_for_manscrpt = 1;
kk = 1;
nreps = 50;
ci_factor = 1.96; % multiply by this factor to plot 95% confidence interval
max_start_vl = zeros(length(brainArea)*length(nnrns),nreps);
max_stop_vl = zeros(length(brainArea)*length(nnrns),nreps);

ll_all = cell(1,4);

limb_names_order = {'LF','LR','RF','RR'};
dolimb = 2;
limb_wise_accrs = cell(length(brainArea),4);
limb_wise_confMats = cell(length(brainArea),4);
limb_wise_mads = cell(length(brainArea),4);

for limb_select = 1:length(limb_names_order)
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
    [phase_accrs,conf_mats_this,phase_mad, xaxis_analysis] = get_this_phase_accr(filename, ...
                                        nreps, nsplits);
    
    xaxis_all = (xaxis_analysis(1:(end-1))+xaxis_analysis(2:end))/2;
    if ii == nnrns(end)
    limb_wise_accrs{jj,limb_select} = phase_accrs;
    limb_wise_mads{jj,limb_select}  = phase_mad;
    limb_wise_confMats{jj,limb_select} = conf_mats_this;

    end
    end
    end
    ll_all{limb_select} = ll_this;
end
%% get average accuracy per limb for all the four areas

X_limb = categorical(limb_names_order);
X_limb = reordercats(X_limb,limb_names_order);
xvalues= (1:numel(X_limb));

stats_save = {};
mult_comparison_save = {};
figure(54)
clf(54)
for kk = 1:length(brainArea)

    this_area_accr = cell2mat(arrayfun(@(c) mean(c{1},2), ...
        limb_wise_accrs(kk,1:length(limb_names_order)),...
        'UniformOutput', false));
    mean_this_area_accr = mean(this_area_accr);
    ntr = size(this_area_accr,1);
    std_this_area_accr = std(this_area_accr);
    qt_level_up = get_dstr_based_CI(this_area_accr,qt_val);
    qt_level_down = get_dstr_based_CI(this_area_accr,100 - qt_val);

    subplot(1,4,kk)
    h = ploterr(xvalues, mean_this_area_accr, ...
                [], std_this_area_accr,'.');

    hold on;
    set([h(:)],  'color', colormaps(1, :),...
        'linewidth',lineWeight); % set a nice color for the lines
     
    % how does the marker look?
    set(h(1), 'markersize', 36, 'marker','.',...
        'markeredgecolor',colormaps(1, :)); % make the marker open
    ylabel('average decoding accuracy')
    title(brainArea{kk});
    if (kk==1) || (kk==3)
    yticks(0.1:0.05:0.2)
    ylim([0.1,0.2])
    start_at = 0.15;
    elseif (kk==2)
    yticks(0.3:0.1:0.5)
    ylim([0.3,0.55])
    start_at = 0.45;
    elseif (kk==4)
    yticks(0.2:0.05:0.4)
    ylim([0.2,0.36])
    start_at = 0.3;
    end
    set(gca, 'Xlim',[xvalues(1)-0.5,xvalues(end) + 0.5],...
        'XTick',xvalues,...
        'XTickLabel',X_limb)

    t = table(this_area_accr(:,1),this_area_accr(:,2),...
        this_area_accr(:,3),this_area_accr(:,4),...
        'VariableNames',limb_names_order);
    Meas = table([1 2 3 4]','VariableNames',{'limb'});
    rm = fitrm(t,'LF-RR~1','WithinDesign',Meas,'WithinModel','limb');
    ranovatbl = ranova(rm);
    stats_save{kk} = ranovatbl;
    T1 = multcompare(rm,'limb');
    T1 = T1([1:3,5,6,9],:);
    T1.("limb_1") = X(T1.("limb_1"))';
    T1.("limb_2") = X(T1.("limb_2"))';
    mult_comparison_save{kk} = T1;
    ylims_here = get(gca, 'ylim');
    kk = 1;
    for tid1 = 1:(length(limb_names_order)-1)
        for tid2 = (tid1+1):length(limb_names_order)

            mysigstar(gca, [tid1 tid2], start_at +kk*0.005, ...
                T1.("pValue")(kk));
            kk = kk +1;
        end
    end

end
set(gcf,'Position',[500 778 1156 350])   
