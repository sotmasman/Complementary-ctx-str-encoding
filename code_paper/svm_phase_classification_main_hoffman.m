function svm_phase_classification_main_hoffman(neurons_to_collate,...
                                svmtrain, load_data_id,limbid_select,...
                                phase_binSize,...
                                do_binshuf, splits,iters)
addpath(genpath('../'));
neurons_to_collate = str2double(neurons_to_collate);
svmtrain = str2double(svmtrain);
load_data_id = str2double(load_data_id);
limbid_select = str2double(limbid_select);
phase_binSize = str2double(phase_binSize);
splits = str2double(splits);
iters = str2double(iters);


disp([num2str(neurons_to_collate),' ',class(neurons_to_collate)] )
disp([num2str(svmtrain),' ',class(svmtrain)] )
disp([num2str(load_data_id),' ',class(load_data_id)] )
disp([num2str(limbid_select),' ',class(limbid_select)] )

disp(['This script will have phase bin size = ', ...
            num2str(phase_binSize), ' deg']);

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
elseif load_data_id ==7
    load_data_from = 'dls_dms_combined';
end
% change the uniq_id to save the results in a new folder. The results are
% saved in '../svm_phase_results/M1_results_Aug27' for M1. 
uniq_id = 'Aug27';
tmp_load_name = [upper(load_data_from(1)), lower(load_data_from(2:end))];

saveresults_at = ['../svm_phase_results/',tmp_load_name,...
                    '_results_',uniq_id,'/'];
check_folder = fullfile('../data',load_data_from);
d = dir(fullfile(check_folder,'*cells*.mat'));

% find the last modified file
[~,idx] = max([d.datenum]);

tmp_filename = d(idx).name;
load(fullfile(check_folder,tmp_filename));

fr_moving_windowsize_all = 4;
smooth_kern = "movemean";
svm_kern = "gaussian";

bin_size_val = 0.025;
bin_size_spks = 0.025;
saveresults = 1;
n_nrn_draws = 50;
start_nrnRep = double((n_nrn_draws/splits)*(iters-1) + 1);
end_nrnRep = double((n_nrn_draws/splits)*iters);
disp(['The reps will be done from ', num2str(start_nrnRep), ...
    ' to ', num2str(end_nrnRep)]);
get_min_trials_all = false; % make sure that we get minimum number of trials
% across all neurons as the maximum number
get_this_many_trials = 200; % would work only if get_min_trials_all is false 
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

saveresults_at = fullfile(saveresults_at,['bin_size_',num2str(phase_binSize)]);
if svmtrain==2
    saveresults_at = fullfile(saveresults_at,"noGridSrch");
end

n_ses = length(walk_prd_for_decd_all_ses);
scrsz = get(0,'screensize');

limb_names_order = {'LF','LR','RF','RR'};

scrsz = get(0,'screensize');
rng default

%%
calculate_unit_activity_vs_phase

%%
collate_n_neurons_phase_data

if saveresults ==1
    fin_save_fold = fullfile(saveresults_at,...
                    [num2str(neurons_to_collate), '_nrns']);
    fin_save_fold = fullfile(fin_save_fold,limb_names_order{limbid_select});
if (exist(fin_save_fold, 'dir') == 0) 
    mkdir(fin_save_fold);
end

xaxis_analysis = binned_degrees;

fin_save_fold = fullfile(fin_save_fold,['all_plot_data_rep_',num2str(start_nrnRep),...
    '_',num2str(end_nrnRep), '.mat']);
save(fin_save_fold,...
        'xaxis_analysis',...
        'y_act_labels',...
        'y_pred_str',...
        'limbid_select');
disp(['saved the accuracy results at: ',fin_save_fold]);
end
% end
