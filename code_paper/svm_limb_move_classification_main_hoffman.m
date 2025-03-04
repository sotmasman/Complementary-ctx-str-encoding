% This function is used to run svm training of time to start. 

function svm_limb_move_classification_main_hoffman(neurons_to_collate,...
                                svmtrain, load_data_id, do_binshuf,...
                                bin_size_val,...
                                classify_time_before)

addpath(genpath('../'));
neurons_to_collate = str2double(neurons_to_collate);
svmtrain = str2double(svmtrain);
load_data_id = str2double(load_data_id);
do_binshuf = str2double(do_binshuf);

bin_size_val = str2double(bin_size_val);
classify_time_before = str2double(classify_time_before);

all_bin_sizes = [0.05,0.1,0.2];
all_time_range = [0.5,1,1.5];
bin_size_val = all_bin_sizes(bin_size_val);
classify_time_before = all_time_range(classify_time_before);
disp([num2str(neurons_to_collate),' ',class(neurons_to_collate)] )
disp([num2str(svmtrain),' ',class(svmtrain)] )
disp([num2str(load_data_id),' ',class(load_data_id)] )

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
% change the uniq_id to save the results in a new folder. The results are
% saved in '../svm_start_results/M1_results_Aug27' for M1. 
uniq_id = 'Aug27';
tmp_load_name = [upper(load_data_from(1)), lower(load_data_from(2:end))];
tmp_bin_timrng_str = ['bin_',num2str(bin_size_val),...
                    '_time_range_',num2str(classify_time_before)];

saveresults_at = ['../svm_start_results/',tmp_load_name,...
                    '_results_',uniq_id,'/',tmp_bin_timrng_str,'/'];
check_folder = fullfile('../data',load_data_from);
d = dir(fullfile(check_folder,'*cells*.mat'));

% find the last modified file
[~,idx] = max([d.datenum]);

% name of file
tmp_filename = d(idx).name;
load(fullfile(check_folder,tmp_filename));

fr_moving_windowsize_all = 4;
smooth_kern = "movemean";
svm_kern = "gaussian";
same_binsize = true;

% bin_size_val = 0.2;
bin_size_spks = 0.025;
% classify_time_before =1.5; 
disp(['Bin Size is ',...
    num2str(bin_size_val),' and classifying time from ',...
    num2str(-classify_time_before), 's to ', num2str(classify_time_before),...
    's.'] );
if (mod(classify_time_before*10,2) == 0)
classify_time_before = classify_time_before + bin_size_val/2;
end
saveresults = 1;
% neurons_to_collate = 250; % "all" or a number less than 200
n_nrn_draws = 50; % Number of draws of "neurons_to_collate" to generate the plot
get_min_trials_all = false; % make sure that we get minimum number of trials
% across all neurons as the maximum number
get_this_many_trials = 50; % would work only if get_min_trials_all is false 
% and this value is greater than 0.
nreps = 50;
neuron_to_plt = 112;
get_time_in = 0;
shuffle_type = "bin_shuffle"; % "bin_shuffle" or "activity_shuffle" or ""

if (~isempty(char(shuffle_type)) && do_binshuf==1)
    saveresults_at = fullfile(saveresults_at,shuffle_type);
    disp(['The results will have this shuffle: ', ...
                    char(shuffle_type)]);
else
    shuffle_type = "";
end

if ~isempty(char(svm_kern))
    saveresults_at = fullfile(saveresults_at,svm_kern);
    
end
if svmtrain==2
    saveresults_at = fullfile(saveresults_at,"noGridSrch");
elseif svmtrain == 3
    saveresults_at = fullfile(saveresults_at,"bayes_opt_new");
    disp('Using new method of bayesian optimization, grid parameters are drawn from last run and limited number of evaluations.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nbins_for_decd = 10;
separate_start_stop_cls = true;
n_ses = length(walk_prd_for_decd_all_ses);
scrsz = get(0,'screensize');
rng default


if (separate_start_stop_cls)
    %%
    calculate_unit_activity_start_stop
    
    %% 
    plot_unit_firing_start_stop
    
    %%
    collate_n_neurons_data
    % % 
    % % %% 
    if  strcmp(neurons_to_collate,"all") 
    leave_one_out_and_train
    else
        calculate_accuracy_stats
    end

    
    if saveresults ==1
        fin_save_fold = fullfile(saveresults_at,[num2str(neurons_to_collate), '_nrns']);
    if (exist(fin_save_fold, 'dir') == 0) 
        mkdir(fin_save_fold);
    end

    xaxis_rms = (-plt_range_around:1:plt_range_around)/framerate;
    xaxis_analysis = [1:total_bins]*bin_size_val - (bin_size_val*(total_bins+1)/2);
    save(fullfile(fin_save_fold,'all_plot_data.mat'),...
            'all_start_rms_vel','all_stop_rms_vel',...
            'all_start_accl',...
            'all_stop_accl',...
            'xaxis_rms',...
            'xaxis_analysis',...
            'all_units_mean_str',...
            'all_units_mean_stp',...
            'start_accrs',...
            'stop_accrs',...
            'confMat_str',...
            'confMat_stp',...
            'bin_size_val',...
            'classify_time_before',...
            'y_act_labels',...
            'y_pred_str',...
            'y_pred_stp');
    disp("saved the accuracy results.");
    end

else
    calculate_unit_activity_time_warped
end
end