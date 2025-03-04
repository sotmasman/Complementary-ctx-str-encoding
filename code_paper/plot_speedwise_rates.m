% this file can be used to get speed coding units in the data. 
function [speed_coding_all,real_Rsq_all,n_units_now] = plot_speedwise_rates(...
                                                    neurons_to_collate,...
                                                     load_data_id)
addpath(genpath('../'));

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
% phase_binSize = 30;

tmp_load_name = [upper(load_data_from(1)), lower(load_data_from(2:end))];
saveresults = 0;
 
saveresults_at = ['../data/svm_speed_results/',tmp_load_name,...
                    '_results_Dec6/'];
check_folder = fullfile('../data',load_data_from);
d = dir(fullfile(check_folder,'data*.mat'));

% find the last modified file
[~,idx] = max([d.datenum]);

% name of file
tmp_filename = d(idx).name;
load(fullfile(check_folder,tmp_filename));

%svm_speed_classification_main
fr_moving_windowsize_all = 4;
smooth_kern = "movemean";

bin_size_val = 0.1;
bin_size_spks = 0.025;
n_nrn_draws = 50;

get_min_trials_all = false; % make sure that we get minimum number of trials
% across all neurons as the maximum number
get_this_many_trials = 18; % would work only if get_min_trials_all is false 
% and this value is greater than 0.
nreps = 18;
neuron_to_plt = 112;
get_time_in = 0;
svm_kern = "gaussian";
shuffle_type = ""; % "bin_shuffle" or "activity_shuffle" or ""


n_ses = length(walk_prd_for_decd_all_ses);
scrsz = get(0,'screensize');

rng default

speed_bin_edges = 50:20:310;

use_ses = 1:n_ses;
%%
calculate_unit_activity_vs_speed

%% Calculate the speed coding cells in each of the areas. 
niter_shuff = 1000;
xaxis_analysis = (speed_bin_edges(1:(end-1)) + speed_bin_edges(2:end))/2;
speed_coding_all = zeros(1,length(mean_spk_speed_data));
real_Rsq_all = zeros(1,length(mean_spk_speed_data));
for ind = 1:length(mean_spk_speed_data)
    this_unit_mean = mean_spk_speed_data{ind};
    [real_corr,p_corr] = corrcoef(this_unit_mean,xaxis_analysis);
    real_corr = real_corr(1,2).^2;
    real_Rsq_all(ind) = real_corr;
    cnt_exceed = 0;
    rng(10)
    for shuf_id  = 1:niter_shuff
        shufx = xaxis_analysis(randperm(length(xaxis_analysis)));
        shuf_corr = corrcoef(this_unit_mean,shufx).^2;
        if (real_corr>(shuf_corr(1,2)))
            cnt_exceed = cnt_exceed+1;
        end
    end
    pct_cnt_exceed = cnt_exceed/niter_shuff;

    if p_corr(1,2)<0.05
        speed_coding_all(ind) = 1;
    end
end


end