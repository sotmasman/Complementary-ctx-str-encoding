
% This script is used in generating single neuron firing rate and firing
% rate stacks for the start and stop case. 
% Plots Figure 1 d and e in the manuscript. 

nnrns = [200]; 
brainArea = {'m1','dms','dls','mpfc'};

binsize = 0.1;
time_range = 1.5;
lineWeight = 0.5;
fontSizeNew = 7;
mkSize = 10;
save_for_manscrpt = 1;
bin_shuf_fold = ['bin_',num2str(binsize),...
                    '_time_range_',num2str(time_range)];

kk = 1;
nreps = 50;
include_sem_fac = 1.96; % for plotting 95% confidence interval
plot_zscored = 1;
ll_all = [];
mm_all = [];
start_areaWise = {};
stop_areaWise = {};
modulated_cells_areawise = {};

set(groot,'defaultAxesXTickLabelRotationMode','manual')

saveAt = '../../../../temp_figures';
figure_manID = 1;
cid = 1;
start_from = 5;


unit_wise_rates_areas = {};
for jj = 1:length(brainArea)
    for ii = nnrns
    
    filename = fullfile('../data',...
        [brainArea{jj}]);

    if exist(filename,'dir')
        load(fullfile(filename,'unit_wise_walking_fRates.mat'));
    
    end
    
    start_areaWise{jj} = all_units_mean_str;
    stop_areaWise{jj} = all_units_mean_stp;
    
    unit_wise_rates_areas{jj} = unit_wise_walk_fRates;
    end
end

unit_set1 = 1; % if selecting unit set 1, make it 1 else 0;
plotThis_unit = [29,108,75,89];

%% Plotting mean firing rate from all trials for all the captured units
figure(15)
clf(15);
figure(16)
clf(16);
for jj = 1:length(brainArea)
    all_units_mean_str = start_areaWise{jj};
    all_units_mean_stp = stop_areaWise{jj};
    [max_fr_bin_str,ind_max_str] = max(all_units_mean_str,[],1);
    [max_fr_bin_stp,ind_max_stp] = max(all_units_mean_stp,[],1);
    
    sem_units_str = zeros(size(all_units_mean_str));
    sem_units_stp = zeros(size(all_units_mean_str));
    mean_str2 = zeros(size(all_units_mean_str));
    mean_stp2 = zeros(size(all_units_mean_str));
    unit_wise_walk_fRates = unit_wise_rates_areas{jj};
    for kk = 1:length(all_units_mean_str)
        ntr = length(unit_wise_walk_fRates{kk,1});
        sem_units_str(:,kk) = std(unit_wise_walk_fRates{kk,1})/sqrt(ntr);
        sem_units_stp(:,kk) = std(unit_wise_walk_fRates{kk,2})/sqrt(ntr);
        mean_str2(:,kk) = mean(unit_wise_walk_fRates{kk,1});
        mean_stp2(:,kk) = mean(unit_wise_walk_fRates{kk,2});
    end
    if plot_zscored ==1
        scr_all_units_str = zscore(all_units_mean_str);
        scr_all_units_stp = zscore(all_units_mean_stp);
        % max_zscr = max([max(scr_all_units_str(:)),max(scr_all_units_stp(:))])
        plot_max = 3;
    else
        scr_all_units_str = all_units_mean_str./max_fr_bin_str;
        scr_all_units_stp = all_units_mean_stp./max_fr_bin_stp; 
        scr_sem_str = sem_units_str./max_fr_bin_str;
        scr_sem_stp = sem_units_stp./max_fr_bin_stp;
        plot_max = 0.9;
    end
    % Plotting the mean firing activity of all neurons areawise on the same plot
    
    figure(15)
    subplot(4,1,jj)
    
    [ll2,~] = boundedline(xaxis_analysis,...
                all_units_mean_str(:,plotThis_unit(jj)),...
                sem_units_str(:,plotThis_unit(jj)),'-',...
                'cmap','k','alpha');
    set(ll2,'linewidth',lineWeight);

    hold on;
    % xlabel('time to start/stop (s)')
    xlabel('time to start (s)')
    ylabel('firing rate (Hz)')
    title(brainArea{jj})
    xlim([xaxis_analysis(1),xaxis_analysis(end)])
    if jj==1
        if unit_set1 == 1
        yticks(4:4:12);
        ylim([4,14]);
        else
       yticks(4:4:12); 
        ylim([1,12]);
        end
    elseif jj==2
        yticks(4:4:12);
        ylim([1,14]);
        % if unit_set1 == 1
    elseif jj==3
        yticks(0:5:20);
        ylim([0,24]);
    elseif jj==4
        yticks(4:4:16);
        ylim([3,16]);
    end
    
    
    
    
    

        fNew = figure(start_from);
        clf(start_from)
        [~,sortorder_str] = sort(ind_max_str); 
        % imagesc([scr_all_units_str(:, sortorder_str)]')
        make_FRstack_img([scr_all_units_str(:, sortorder_str)]',xaxis_analysis,...
            plot_max,plot_zscored);
        hold on;
        xlabel('time to start (s)')
        ylabel('ordered cell #')
        
        
        title(brainArea{jj});
        set(gca, ...
        'ytick',0:50:200);
        nosqr = 0;
        SetFigBoxDefaults
        hNew = findobj(figure(start_from), 'type', 'axes'); 
        set(hNew,'units','inches','position',[1,1,1,1])
        start_from = start_from + 1;
    
    

end
figure(15);
set(gcf,'Position',[653 131 233 738])   
