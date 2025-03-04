% this file gets one unit from each of the four areas and generates firing
% rate vs stance start time plots and firing rate vs limb phase plots.
% Plots Figure 5b of the manuscript. 
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
    
end

%%
nosqr = 0;
figure(52)
clf(52);
degree_div = 15;
plot_div = 90/degree_div;
for jj = 1:length(areaNames)
    all_units_mean_lr = all_areaStats{jj}.spikesperangle_lr;
    [b, sortorder_lr] = sort(wrapToPi(...
        all_areaStats{jj}.preferred_angle_lr), 'ascend');  %sort by lowest to highest preferred spike-limb phase.
    vect_length_lr = all_areaStats{jj}.vectorlength_lr;
    vect_angle_lr = all_areaStats{jj}.preferred_angle_lr;

    vect_length_lf = all_areaStats{jj}.vectorlength_lf;
    vect_angle_lf = all_areaStats{jj}.preferred_angle_lf;

    vect_length_rf = all_areaStats{jj}.vectorlength_rf;
    vect_angle_rf = all_areaStats{jj}.preferred_angle_rf;

    vect_length_rr = all_areaStats{jj}.vectorlength_rr;
    vect_angle_rr = all_areaStats{jj}.preferred_angle_rr;

    dbl_degrees = all_areaStats{jj}.doubledegrees;
    binned_degrees = all_areaStats{jj}.binned_degrees;

    [max_fr_bin_lr,ind_max_lr] = max(all_units_mean_lr,[],2);

    if plot_zscored ==1
        scr_all_units_lr = zscore(all_units_mean_lr')';

        plot_max = 3;
    else
        scr_all_units_lr = all_units_mean_lr./max_fr_bin_lr;
        plot_max = 0.9;
    end
    max_div_units_lr = all_units_mean_lr./max_fr_bin_lr;
    figure(52);

    subplot(1,4,jj);
    plot(dbl_degrees,...
         [all_units_mean_lr(plotThis_unit(jj),:),...
         all_units_mean_lr(plotThis_unit(jj),2:end)],'color',...
                    colormaps(1,:),'linewidth',lineWeight);
    hold on;

    % set(gca,'linewidth',lineWeight);

    xlabel('LR limb phase (deg)')
    ylabel('firing rate (Hz)')
    set(gca,'XTick',[0:plot_div*degree_div:dbl_degrees(end)])  %note: plot limits are different from plot_unitstack. 
    set(gca,'XTickLabel', [min(dbl_degrees):plot_div*degree_div...
                :max(dbl_degrees)])
    set(gca,'Xlim',[dbl_degrees(1),dbl_degrees(25)]);
    title(areaNames{jj})
    if jj ==1

        ylim([5.5,9]);
        yticks(4:2:8);
    elseif (jj==2)
    ylim([0,15]);
    yticks(0:5:15);
    elseif (jj==3)
        ylim([1.5,4.5]);
        yticks(2:2:4);
    elseif (jj==4)
    ylim([0,8]);
    yticks(0:4:8);
    end

end
set(gcf,'Position',[680 578 1730 316])   
