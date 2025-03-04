% This file calculates RMSE for each of the area pre start, post start. 
% Plots Supplementary Figure 1d of the manuscript. 

nnrns = [200]; 
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
qt_val = 95;
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

bf_comparison_stop = zeros(size(bf_comparison_start));
aft_comparison_stop = zeros(size(bf_comparison_start));
during_comparison_stop = zeros(size(bf_comparison_start));



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
    [str_rmse, stp_rmse] = calculate_loc_model_rmse(y_act_labels, y_pred_str,...
                            y_pred_stp,xaxis_analysis);

    start_bf = str_rmse(:,before_accr_bins);
    start_bf = mean(start_bf,2);

    start_aft = str_rmse(:,after_accr_bins);
    start_aft = mean(start_aft,2);

    start_during = str_rmse(:,during_comparison_bins);
    start_during = start_during(:);
   
    bf_comparison_start(:,kk) = start_bf;
    aft_comparison_start(:,kk) = start_aft;
    during_comparison_start(:,kk) = start_during;

    stop_bf  = stp_rmse(:,before_accr_bins);
    stop_bf = mean(stop_bf,2);

    stop_aft = stp_rmse(:,after_accr_bins);
    stop_aft = mean(stop_aft,2);

    stop_during = stp_rmse(:,during_comparison_bins);
    stop_during = stop_during(:);

    bf_comparison_stop(:,kk) = stop_bf;
    aft_comparison_stop(:,kk) = stop_aft;
    during_comparison_stop(:,kk) = stop_during;
    kk = kk+1;
    

    end
end

tmp_cell = {'start','stop'};
tmp_cell2 = {'pre start', 'at start','post start',...
                'pre stop', 'at stop', 'post stop'};
tmp_dat_all{1} = bf_comparison_start;
tmp_dat_all{2} = during_comparison_start;
tmp_dat_all{3} = aft_comparison_start;
tmp_dat_all{4} = bf_comparison_stop;
tmp_dat_all{6} = aft_comparison_stop;

tmp_dat_all{5} = during_comparison_stop;
stats_save = {};
mult_comparison_save = {};
for compid = 1:6
    thisReg = {};
    this_tmp = tmp_dat_all{compid};
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
figure(1)
clf(1)

nosqr = 1;
for ptid = [1,3]
    subplot_tr = [ 1,3,ptid];
    subplot(subplot_tr(1),subplot_tr(2),subplot_tr(3))
    meanprestartaccr = mean(tmp_dat_all{ptid});
    SDprestartaccr = std(tmp_dat_all{ptid},[],1);
    qt_level_up = get_dstr_based_CI(tmp_dat_all{ptid},qt_val);
    qt_level_down = get_dstr_based_CI(tmp_dat_all{ptid},100 - qt_val);
        xvalues= (1:numel(X));

    h = ploterr(xvalues, meanprestartaccr, ...
                    [], SDprestartaccr, ...
                    '.');

    hold on;
    set([h(:)],  'color', colormaps(1, :),...
    'linewidth',lineWeight); % set a nice color for the lines
    % how does the marker look?
    set(h(1), 'markersize', mkSize, 'marker','.',...
        'markeredgecolor',colormaps(1, :)); % make the marker open
    
    ylims_here = get(gca, 'ylim');
    if ptid ==1
        ylim([min(abs(ylims_here)),1]);
    else

        ylim([min(abs(ylims_here))*0.9,1]);
    end
    
    set(gca, 'YTick',0.4:0.2:1)
    set(gca, 'Xlim',[xvalues(1)-0.5,xvalues(end) + 0.5],...
    'XTick',xvalues,...
    'XTickLabel',X)
    ylabel([tmp_cell2{ptid}, ' RMSE (s)']);
    SetFigBoxDefaults
    set(gcf,'Position',[600 50 1200 1200])   
        
    SetFigBoxDefaults
    mutl_tmp = mult_comparison_save{ptid};
    kk = 1;
    for tid1 = 1:(length(brainArea)-1)
        for tid2 = (tid1+1):length(brainArea)
            dat1 = tmp_dat_all{ptid}(:,tid1);
            dat2 = tmp_dat_all{ptid}(:,tid2);

            mysigstar(gca, [tid1 tid2], max(abs(ylims_here)) +kk*0.01, ...
                mutl_tmp.("P-value")(kk));
            kk = kk +1;
        end
    end

end
set(gcf,'Position',[680 578 1156 400])   
