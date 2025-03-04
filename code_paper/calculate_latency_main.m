% This is the main script for calculating the time at which the activity 
% modulated from baseline.

fr_moving_windowsize_all = 4;
smooth_kern = "movemean";

same_binsize = true;

bin_size_val = 0.1; % the original bin size was 0.1
bin_size_spks = 0.025; 
classify_time_before =1.5; 
baseline_period = [-1,-0.8];

if (mod(classify_time_before,bin_size_val) == 0)
classify_time_before = classify_time_before + bin_size_val/2;
end
saveresults = 1;
neurons_to_collate = 200; % "all" or a number less than 200

% change the parameter below
% for DMS, load_data_id = 1
% for M1, load_data_id = 2
% for mPFC, load_data_id = 3
% for DLS, load_data_id = 6
load_data_id  = 6;

% change the variable below, uniq_id
% This identifier is added to the folder name while saving the results. 
% For example, to get the results for M1, change load_data_id = 2 and if uniq_id = 'Feb5',
% results are saved at '../latency_results/M1_results_Feb5_bsl_0.8_binSize_0.1'
uniq_id = 'Feb5';


if load_data_id ==1
    load_data_from = 'dms';
elseif load_data_id == 2
    load_data_from = 'm1';
elseif load_data_id == 3
    load_data_from = 'mpfc';
elseif load_data_id ==4
    load_data_from = 'striatum_D1';
elseif load_data_id ==5
    load_data_from = 'striatum_D2';
elseif load_data_id ==6
    load_data_from = 'dls';
elseif load_data_id == 7
    load_data_from = 'dls_dms_combined';
end

check_folder = fullfile('../data',load_data_from);
d = dir(fullfile(check_folder,'*data*.mat'));

% find the last modified file
[~,idx] = max([d.datenum]);

% name of file
tmp_filename = d(idx).name;
load(fullfile(check_folder,tmp_filename));


numberofjitters = 1000;
max_jittertime = 0.5; 
calculate_jitStats = 0;
neuron_to_plt = 112;
n_ses = length(walk_prd_for_decd_all_ses);
scrsz = get(0,'screensize');
location_str = [upper(load_data_from(1)), lower(load_data_from(2:end))];

rng default

%%
calculate_unit_activity_start_stop_for_latency


%% 
if calculate_jitStats ==1
    unit_wise_bsl_comparison_v3
else
    unit_wise_bsl_comparison_v2
end
%%


if saveresults ==1
    saveresults_at = ['../latency_results/',location_str,...
        '_results_',uniq_id,'_bsl_',...
        num2str(-baseline_period(2)),'_binSize_',num2str(bin_size_val),'/',...
        num2str(neurons_to_collate), '_nrns'];
    if (exist(saveresults_at, 'dir') == 0) 
        mkdir(saveresults_at);
    end

xaxis_rms = (-plt_range_around:1:plt_range_around)/framerate;
xaxis_analysis = [1:total_bins]*bin_size_val - (bin_size_val*(total_bins+1)/2);
save(fullfile(saveresults_at,'all_plot_data.mat'),...
        'sig_positive_cells','sig_negative_cells',...
        'baseline_period',...
        'xaxis_analysis',...
        'all_units_mean_str',...
        'all_units_sem_str',...
        'all_units_mean_stp',...
        'all_units_sem_stp');
end
