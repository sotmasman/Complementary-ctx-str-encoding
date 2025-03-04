% This file plots the pre start, at start and post start accuracies for
% all the areas separately for all different combinations of neurons. 
% Plots Supplementary Figure 1 a and b of the manuscript. 

nnrns = [25,50,100,150,200]; 
brainArea = {'Mpfc','M1','Dms','Dls'};
X = categorical({'mPFC','M1','DMS','DLS'});
X = reordercats(X,{'mPFC','M1','DMS','DLS'});
colormaps = [0,0,0;
             1,0,0;
             0.9290,0.6940,0.1250];
binsize = 0.2;
time_range = 1.5;
lineWeight = 0.5;
fontSizeNew = 7;
mkSize = 18;
ylim_all = 0.6;
include_sem_fac = 1.96;
qt_val = 1;
before_accr_time = [-0.9,-0.3];
after_accr_time = [0.3,0.9];
bin_shuf_fold = ['bin_',num2str(binsize),...
                    '_time_range_',num2str(time_range)];

% change the uniq_id to pick results from a new folder. 
uniq_id = 'Feb20/'; 

plot_ci = 1;
kk = 1;
nreps = 50;
max_start_vl = zeros(length(brainArea)*length(nnrns),nreps);
max_stop_vl = zeros(length(brainArea)*length(nnrns),nreps);
st_ind = floor(15/3);
end_ind = 2*st_ind + 1;
ll_all = [];
mm_all = [];
bf_comparison_start = zeros(nreps,length(brainArea)*length(nnrns));
aft_comparison_start = zeros(size(bf_comparison_start));
during_comparison_start = zeros(size(bf_comparison_start));

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

    
    before_accr_bins = find((xaxis_analysis>before_accr_time(1)) & ...
                        (xaxis_analysis<before_accr_time(end)));
    after_accr_bins = find((xaxis_analysis>after_accr_time(1)) & ...
                          (xaxis_analysis<after_accr_time(end)));
    during_comparison_bins = find((xaxis_analysis==0));
    
    start_bf = start_accrs(:,before_accr_bins);
    start_bf = mean(start_bf,2);

    start_aft = start_accrs(:,after_accr_bins);
    start_aft = mean(start_aft,2);

    start_during = start_accrs(:,during_comparison_bins);
    start_during = start_during(:);
    
    bf_comparison_start(:,kk) = start_bf;
    aft_comparison_start(:,kk) = start_aft;
    during_comparison_start(:,kk) = start_during;
    kk = kk+1;
    

    end
end
tmp_dat_all = {};
tmp_cell = {'start','stop'};
tmp_cell2 = {'pre start', 'at start','post start',...
                'pre stop', 'at stop', 'post stop'};
tmp_dat_all{1} = bf_comparison_start;
tmp_dat_all{2} = during_comparison_start;
tmp_dat_all{3} = aft_comparison_start;


%%
figure(1)
clf(1)
nosqr = 1;

stats_save = {};
mult_comparison_save = {};

for ptid = [1,3]
    
    meanprestartaccr = mean(tmp_dat_all{ptid});
    SDprestartaccr = std(tmp_dat_all{ptid},[],1);
    qt_level_up = get_dstr_based_CI(tmp_dat_all{ptid},qt_val);
    qt_level_down = get_dstr_based_CI(tmp_dat_all{ptid},100 - qt_val);

    ncombs = numel(nnrns);
    xvalues= (1:ncombs);
    for jj = 1:length(brainArea)
        select_only = ((jj-1)*ncombs+1):jj*ncombs;

        thisnrn = {};
        this_tmp = tmp_dat_all{ptid}(:,select_only);
        this_comp = [];
        for ncnt = 1:ncombs
            all_nrn_tmp = this_tmp(:,ncnt);
            thisnrn = [thisnrn,repelem({char(num2str(ncnt))},1,length(all_nrn_tmp))];
            this_comp = [this_comp,all_nrn_tmp'];
        end
        figure(2)
        clf(2)
        [this_stats, this_multcompare] = do_1way_anova(thisnrn,this_comp);
        stats_save{(ptid-1)*length(brainArea)+jj} = this_stats;
        mult_comparison_save{(ptid-1)*length(brainArea)+jj} = this_multcompare;

        figure(1)
        subplot_tr = [ length(brainArea),3,(jj-1)*3+ptid];
    subplot(subplot_tr(1),subplot_tr(2),subplot_tr(3))
    h = ploterr(xvalues, meanprestartaccr(select_only), ...
                    [], SDprestartaccr(select_only), ...
                    '-');

    hold on;
    set([h(:)],  'color', colormaps(1, :),...
    'linewidth',lineWeight); % set a nice color for the lines
    % how does the marker look?
    set(h(1), 'markersize', mkSize, 'marker','.',...
        'markeredgecolor',colormaps(1, :)); % make the marker open
    
    ylims_here = get(gca, 'ylim');
    
    yticks_here = get(gca,'YTick');
    ylim([min(abs(ylims_here))*0.8,max(abs(ylims_here))*1.1]);
    
    set(gca, 'YTick',0:0.1:0.5)
    set(gca, 'Xlim',[xvalues(1)-0.5,xvalues(end) + 0.5],...
    'XTick',xvalues,...
    'XTickLabel',nnrns)
    ylabel([tmp_cell2{ptid}, ' decoding accuracy']);
    xlabel('# of units');
    title(string(X(jj)));
    SetFigBoxDefaults
    set(gcf,'Position',[600 50 1200 1200])   
    end

end