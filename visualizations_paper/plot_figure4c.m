% this file gets one unit from each of the four areas and generates firing
% rate vs stance start time plots.
% Plots figure 4c of the manuscript. 

lineWeight  =0.5;
fontSizeNew = 7;
areaNames = {'mpfc','m1','dms', 'dls'};
aligned_tmin = -0.75; %for stance-aligned limb movements and firing rate.
aligned_tmax = 0.75; %for stance-aligned limb movements and firing rate.
rate_timebinsize = 0.025; %for stance-aligned firing rate.
spikephase_smoothwindow = 5;  %for smoothing spike-phase distribution and stance-aligned firing rate.
all_areaStats = {};
all_areaStrides = {};
all_areaStrideRates = {};
plot_zscored = 1;
colormaps = [0,0,0;
             1,0,0;
             0.9290,0.6940,0.1250];

set(groot,'defaultAxesXTickLabelRotationMode','manual')

for ii = 1:length(areaNames)
    filename = fullfile('../data/phase_coding_stats',areaNames{ii});
    d = dir(fullfile(filename,'*.mat'));

    % find the last modified file
    [~,idx] = max([d.datenum]);
    
    % name of file
    tmp_filename = d(idx).name;
    load(fullfile(filename,tmp_filename));
    all_areaStats{ii} = stats;
    all_areaStrides{ii} = strides;
    all_areaStrideRates{ii} = rateperstride;

    
end
limb_order = {'LF','LR','RF','RR'};
%% Plotting mean firing rate from all trials for all the captured units
nosqr = 1;
plotThis_unit = [35,7,68,88];

figure(51)
clf(51);
for jj = 1:length(areaNames)

    check_folder = fullfile('../data',areaNames{jj});
    d = dir(fullfile(check_folder,'data*.mat'));
    
    % find the last modified file
    [~,idx] = max([d.datenum]);
    
    % name of file
    tmp_filename = d(idx).name;
    load(fullfile(check_folder,tmp_filename));
    

    this_area_rates =  all_areaStrideRates{jj};
    this_area_strides = all_areaStrides{jj};
    ncells = length(this_area_rates.spiketimes);
    
    this_unit_times = this_area_rates.spiketimes{plotThis_unit(jj)};
    subject_id = this_area_rates.subjectind{plotThis_unit(jj)};
    this_sub_limbtostance = limbs_to_stance_all_ses{subject_id};
    aligned_stance_timebins = this_sub_limbtostance.aligned_stance_timebins;
    this_sub_limbtostance = this_sub_limbtostance.aligned_stance_lr;
    meanlrstance = mean(this_sub_limbtostance,1);
    semlrstance = std(this_sub_limbtostance,1)/sqrt(size(this_sub_limbtostance,1));

    this_area_lr_stance_start = ...
                    this_area_strides.lr_stance_start_inrange{subject_id};
    [meanrate, SEMrate, ratetimebins] = plot_meanrate_noplot(...
        this_area_lr_stance_start, ...
        this_unit_times, rate_timebinsize, aligned_tmin, ...
        aligned_tmax+spikephase_smoothwindow*rate_timebinsize, ...
        spikephase_smoothwindow);
    meanrate = meanrate(1:(end-spikephase_smoothwindow));
    SEMrate = SEMrate(1:(end-spikephase_smoothwindow));
    if plot_zscored ==1
        scr_lr = zscore(meanrate);
        
        plot_max = 3;
    else
        max_rate = max(meanrate);
        scr_lr = meanrate./max_rate;
        scr_SEM = SEMrate./max_rate;
        plot_max = 0.9;
    end
    

    %%

    subplot(2,4,jj)
    stride_rate = 1./this_area_strides.lr_stride_duration_inrange{subject_id};
    titletext = 'LR';    
    [b, ordered_by_stride_rate] = sort(stride_rate, 'ascend');
    
    plotraster_gait(this_area_lr_stance_start(ordered_by_stride_rate), ...
        this_unit_times', aligned_tmin, aligned_tmax, 'dots');
    hold on;
    if (jj==2)||(jj==4)
        yticks(0:200:800);
    end
    ntrs_here = length(this_area_lr_stance_start);
    xplt_sct= zeros(1,ntrs_here);
    scatter(xplt_sct,...
        1:ntrs_here, 0.1, 'r', 'o', 'MarkerFaceColor', 'r');
    scatter(1./b,1:ntrs_here, 0.1, 'r', 'o', 'MarkerFaceColor', 'r');

    xlabel(['LR stance start time (s)'])
    ylabel('stride #')
    title(areaNames{jj})
    xticks(-aligned_tmax:0.75:aligned_tmax);

    axis([aligned_tmin aligned_tmax 0 length(this_area_lr_stance_start)+0.5])
    
    %%

    subplot(2,4,4+jj)
    ratetimebins = ratetimebins(1:(end-spikephase_smoothwindow));
    yyaxis left
    [ll2,~] = boundedline(ratetimebins,...
                meanrate,...
                SEMrate,'-',...
                'cmap',colormaps(1,:),'alpha');
    set(ll2,'linewidth',lineWeight);
    hold on;
    if jj ==1

        ylim([5,9]);
        yticks(5:2:9);
    elseif (jj==2)
        ylim([0,12]);
        yticks(0:5:10);
    elseif (jj==3)
        ylim([1.5,4.5]);
        yticks(0:2:4);
    elseif (jj==4)
        ylim([0,6]);
        yticks(0:2:6);
    end
    xlabel('LR stance start time (s)')
    ylabel('firing rate (Hz)')
    hold off;

    yyaxis right
    hold on;
     
    [mmn2,~] = boundedline(aligned_stance_timebins,...
                meanlrstance,...
                semlrstance,'-',...
                'cmap',colormaps(2,:),'alpha');
    ylim([-12.5,10]);
    yticks(-10:10:10);
    set(ll2,'linewidth',lineWeight);
    ylabel('limb position (mm)')
    title(areaNames{jj})   
    
    xticks(-aligned_tmax:0.75:aligned_tmax);
    xlim([ratetimebins(1),ratetimebins(end)])
    % SetFigBoxDefaults
    set(gca, 'XColor', 'k', 'YColor', 'k')  %changes axis color
    set(gca, 'box', 'off')   
    if exist('fontSizeNew','var')
    set(gca,'FontSize',fontSizeNew,'TickDir','out')
    else
        set(gca,'FontSize',12,'TickDir','out')
    end
    set(gca,'TickDir', 'out', 'TickLength',[0.02, 0.02])

end
figure(51);
set(gcf,'Position',[123 105 1643 609])   

