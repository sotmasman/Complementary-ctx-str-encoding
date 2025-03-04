
%% Plotting mean firing rate from all trials for all the captured units
total_bins = size(unit_wise_walk_fRates{n_units_now,2},2);
all_units_mean_str = zeros(total_bins, n_units_now);
all_units_mean_stp = zeros(total_bins, n_units_now);
max_fr_bin_str = zeros(n_units_now,1);
max_fr_bin_stp = zeros(n_units_now,1);
for kk = 1:n_units_now
    mean_fr_str = mean(unit_wise_walk_fRates{kk,1});
    mean_fr_stp = mean(unit_wise_walk_fRates{kk,2});
    all_units_mean_str(:,kk) = mean_fr_str;
    [~,ind_max] = max(mean_fr_str);
    max_fr_bin_str(kk) = ind_max;
    all_units_mean_stp(:,kk) = mean_fr_stp;
    [~,ind_max] = max(mean_fr_stp);
    max_fr_bin_stp(kk) = ind_max;
end

%% Plotting the mean firing activity of all neurons. 
figure(15)
clf(15);
meanstartrate = mean(all_units_mean_str,2);
SDstartrate = std(all_units_mean_str,[],2);
meanstoprate = mean(all_units_mean_stp,2);
SDstoprate = std(all_units_mean_stp,[],2);
boundedline([1:total_bins]*bin_size_val - (bin_size_val*(total_bins+1)/2),...
                meanstoprate, SDstoprate/sqrt(n_units_now), 'r')
hold on
boundedline([1:total_bins]*bin_size_val - (bin_size_val*(total_bins+1)/2),...
            meanstartrate, SDstartrate/sqrt(n_units_now), 'b')
xlabel('time (s)')
ylabel('mean FR')
title(['start/stop FR']); 
SetFigBoxDefaults
%%
zscr_all_units_str = zscore(all_units_mean_str);
zscr_all_units_stp = zscore(all_units_mean_stp);
%%

figure(16)
clf(16);
subplot(2,1,1)
[~,sortorder_str] = sort(max_fr_bin_str); 
imagesc([zscr_all_units_str(:, sortorder_str)]')
xlabel('time to walk start')
ylabel('ordered cell #')
set(gca,'Xlim',[0,total_bins]+(bin_size_val*total_bins/2))
set(gca,'XTick',[1:total_bins])  %note: plot limits are different from plot_unitstack. 
set(gca,'XTickLabel', [1:total_bins]*bin_size_val - (bin_size_val*(total_bins+1)/2) )
SetFigBoxDefaults

[~,sortorder_stp] = sort(max_fr_bin_stp); 

subplot(2,1,2)
% [~,sortorder_str] = sort(max_fr_bin_str); 
imagesc([zscr_all_units_stp(:, sortorder_stp)]')
xlabel('time to walk end')
ylabel('ordered cell #')
set(gca,'Xlim',[0,total_bins]+(bin_size_val*total_bins/2))
set(gca,'XTick',[1:total_bins])  %note: plot limits are different from plot_unitstack. 
set(gca,'XTickLabel', [1:total_bins]*bin_size_val - (bin_size_val*(total_bins+1)/2) )
SetFigBoxDefaults


%%
figure(17)
clf(17);
plot_combined_results(@pop_plot_default,...
        'speedAndacceleration', false,...
        'spread', false,...
        'meanFR', false,...
        'FRstacks',true,...
                    'xaxis_analysis', [1:total_bins]*bin_size_val - (bin_size_val*(total_bins+1)/2),...
                    'startFR', all_units_mean_str, ...
                    'stopFR', all_units_mean_stp);
set(gcf,'Position',[2000   141   857   400])   
