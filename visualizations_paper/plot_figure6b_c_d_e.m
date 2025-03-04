% It calculates decoding accuracies for LR limb phase for all the areas
% separately and also generates the confusion matrices in the figure. 
% It also calculates the limb average decoding accuracy and also the mean absolute
% errors. 
% Plots figure 6 b, c, d and e of the manuscript.

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
figure(50)
clf(50)

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

        if limb_select == dolimb
            subplot(1,4,jj)
            
            mean_val = mean(phase_accrs);
            SDstartaccr = std(phase_accrs,[],1);
            qt_level_up = get_dstr_based_CI(phase_accrs,qt_val);
            qt_level_up = qt_level_up - mean_val' ;
            qt_level_down = get_dstr_based_CI(phase_accrs,100 - qt_val);
            qt_level_down = mean_val' - qt_level_down;

            [ll,~] = boundedline(xaxis_all*180/pi,...
                    mean_val, SDstartaccr,...
                    'cmap', colormaps(1,:),'alpha');

            set(ll,'linewidth',lineWeight);
            ll_this = [ll_this,ll];
            
            hold on
            
        end
    end
    end
    end
    ll_all{limb_select} = ll_this;
end
%% only when you are adding shuffled data
if add_shuffle == 1
for limb_select = dolimb
    
    for jj = 1:length(brainArea)
    for ii = nnrns
    
    filename = fullfile('../data/svm_phase_results',...
        fullfile([brainArea{jj},'_results_',uniq_id],'bin_shuffle/gaussian/bin_size_30'),...
        [num2str(ii),'_nrns/',limb_names_order{limb_select},'/']);
    if exist(filename,'dir')
    allfilenames = dir(fullfile( filename,'*.mat'));
    nsplits = length(allfilenames);

    else
        error('Shuffle folder not found.')
    end
    [phase_accrs,conf_mats_this,phase_mad,xaxis_analysis] = get_this_phase_accr(filename, ...
                                        nreps, nsplits);
    qt_bin_shuf = get_dstr_based_CI(phase_accrs,qt_val);
    xaxis_all = (xaxis_analysis(1:(end-1))+xaxis_analysis(2:end))/2;
    qt_madbin_shuf = get_dstr_based_CI(phase_mad,100-qt_val);

    subplot(1,4,jj)

    mean_val = mean(phase_accrs);
    
    SDstartaccr = std(phase_accrs,[],1);
    
    plot(xaxis_all*180/pi,qt_bin_shuf, ...
                '--','color',colormaps(3,:),...
                'linewidth',lineWeight);
    
    hold on;

    end
    end
    
end
end

for jj = 1:length(brainArea)
    
        subplot(1,4,jj)
        ylim([0.05,0.5])
        xlim([0,360])
        xticks(0:90:360)
        xlabel([limb_names_order{dolimb},' limb phase (deg)'] )
        ylabel('decoding accuracy')
        title(string(X(jj)))
        SetFigBoxDefaults

    
end
set(gcf,'Position',[680 578 1156 230])   



%% draw Confusion Matrices for all limbs for the different areas
figure(51)
clf(51)
xaxis_all = xaxis_all*180/pi;
for jj=dolimb
    for kk = 1:length(brainArea)
    subplot(1,4,kk)
    if repeat_twice ==0
    make_confusion_img(limb_wise_confMats{kk,jj},'start',xaxis_all,0.4);
    title([brainArea{kk},', ',limb_names_order{jj}]);
    xlabel([limb_names_order{jj},' predicted phase (deg)']); 
    ylabel([limb_names_order{jj},' actual phase (deg)']);
    len_xaxi = length(xaxis_all);
    
    set(gca, 'xtick',1:3:len_xaxi,...
            'ytick',1:3:len_xaxi,...
            'XTickLabel',xaxis_all(1:3:len_xaxi),...
            'YTickLabel', xaxis_all(1:3:len_xaxi));
    SetFigBoxDefaults
    else
        this_mat = limb_wise_confMats{kk,jj};
        this_mat = repmat(this_mat,2);
        xaxis_new = [xaxis_all, xaxis_all+ 360];
        make_confusion_img(this_mat,'start',xaxis_new,0.4);
    title([brainArea{kk},', ',limb_names_order{jj}]);
    xlabel([limb_names_order{jj},' predicted phase (deg)']); 
    ylabel([limb_names_order{jj},' actual phase (deg)']);
    len_xaxi = length(xaxis_new);
    
    set(gca, 'xtick',1:3:len_xaxi,...
            'ytick',1:3:len_xaxi,...
            'XTickLabel',xaxis_new(1:3:len_xaxi),...
            'YTickLabel', xaxis_new(1:3:len_xaxi));
    SetFigBoxDefaults    
    end    
    end
   
end
set(gcf,'Position',[500 778 1156 230])   

%% get average limb wise accuracies and Mean Absolute Error for all areas.
figure(53);
Region = [];
all_area_accrs = [];
all_area_mads = [];
for kk = 1:length(brainArea)

    this_area_accr = cell2mat(arrayfun(@(c) mean(c{1},2), ...
        limb_wise_accrs(kk,dolimb),...
        'UniformOutput', false));
    all_area_accrs = [all_area_accrs;this_area_accr];
    Region = [Region; repmat(brainArea(kk),size(this_area_accr,1),1)];
    ntr = size(this_area_accr,1);

    this_area_mad = cell2mat(arrayfun(@(c) mean(c{1},2), ...
        limb_wise_mads(kk,dolimb),...
        'UniformOutput', false));
    all_area_mads = [all_area_mads; this_area_mad];
end

all_area_accrs = mean(all_area_accrs,2);
[this_stats, this_multcompare] = do_1way_anova(Region,all_area_accrs);

[mad_stats, mad_multcompare] = do_1way_anova(Region,all_area_mads);

%%
figure(52);
clf(52);

xvalues= (1:numel(X));

for kk = 1:length(brainArea)
    subplot(2,1,1);
    thisar_acc = all_area_accrs(((kk-1)*ntr+1):(kk*ntr));
    qt_level_up = get_dstr_based_CI(thisar_acc,qt_val);
    qt_level_down = get_dstr_based_CI(thisar_acc,100 - qt_val);

    h = ploterr(kk, mean(thisar_acc), ...
            [], std(thisar_acc),'.',...
            'abshhxy',0.15);

    hold on;
    set([h(:)],  'color', colormaps(1, :),...
        'linewidth',lineWeight); % set a nice color for the lines

    % how does the marker look?
    set(h(1), 'markersize', 36, 'marker','.',...
        'markeredgecolor',colormaps(1, :)); % make the marker open

    subplot(2,1,2);
    thisar_mad = all_area_mads(((kk-1)*ntr+1):(kk*ntr));
    qt_level_up = get_dstr_based_CI(thisar_mad,qt_val);
    qt_level_down = get_dstr_based_CI(thisar_mad,100 - qt_val);

    h = ploterr(kk, mean(thisar_mad), ...
            [], std(thisar_mad),'.',...
                'abshhxy',0.15);

    hold on;
    set([h(:)],  'color', colormaps(1, :),...
        'linewidth',lineWeight); % set a nice color for the lines
         
            
    % how does the marker look?
    set(h(1), 'markersize', 36, 'marker','.',...
        'markeredgecolor',colormaps(1, :)); % make the marker open
end

kk = 1;
for tid1 = 1:(length(brainArea)-1)
    for tid2 = (tid1+1):length(brainArea)

        subplot(2,1,1);
        mysigstar(gca, [tid1 tid2], 0.35 +kk*0.01, ...
            this_multcompare.("P-value")(kk));
        subplot(2,1,2);
        mysigstar(gca, [tid1 tid2], 70 +kk*2, ...
            mad_multcompare.("P-value")(kk));
        kk = kk +1;
    end
end
subplot(2,1,1);
ylabel('limb average decoding accuracy')
yticks(0.1:0.1:0.5)
ylim([0.1,0.4])
set(gca, 'Xlim',[xvalues(1)-0.5,xvalues(end) + 0.5],...
    'XTick',xvalues,...
    'XTickLabel',X)

subplot(2,1,2);
ylabel('limb average mean absolute error (deg)')
yticks(0:30:60)
ylim([20,75])
set(gca, 'Xlim',[xvalues(1)-0.5,xvalues(end) + 0.5],...
    'XTick',xvalues,...
    'XTickLabel',X)
set(gcf,'Position',[680 249 359 749])   


