% this file is used to plot one unit from each of the four areas. mPFC, M1,
% DMS and DLS.
% Plots figure 3a of the manuscript. 

close all;
addpath(genpath('../'));
figure(1);
clf(1);

for load_data_id = 1:4
    if load_data_id ==1
        load_data_from = 'dms';
    elseif load_data_id == 2
        load_data_from = 'm1';
    elseif load_data_id == 3
        load_data_from = 'mpfc';
    elseif load_data_id ==4
        load_data_from = 'dls';
    end
    
    tmp_load_name = [upper(load_data_from(1)), lower(load_data_from(2:end))];
    saveresults = 0;
    fontSizeNew = 7;
    
    check_folder = fullfile('../data',load_data_from);
    d = dir(fullfile(check_folder,'data*.mat'));
    
    % find the last modified file
    [~,idx] = max([d.datenum]);
    
    % name of file
    tmp_filename = d(idx).name;
    load(fullfile(check_folder,tmp_filename));
    
    fr_moving_windowsize_all = 4;
    smooth_kern = "movemean";
    
    n_ses = length(walk_prd_for_decd_all_ses);
    scrsz = get(0,'screensize');
    
    rng default
    
    bin_size_val = 0.1;
    bin_size_spks = 0.025;
    speed_bin_edges = 50:20:310;
    
    use_ses = 1:n_ses;
    %%
    calculate_unit_activity_vs_speed
    %%
    unitN = [89,90,132,172];
    subplot(1,4,load_data_id)
    for ind = unitN(load_data_id)
    
        xaxis_analysis = (speed_bin_edges(1:(end-1)) + speed_bin_edges(2:end))/2;
        [ll2,~] = boundedline(xaxis_analysis,...
                        mean_spk_speed_data{ind},...
                        SEM_spk_speed_data{ind},'-',...
                        'cmap','k','alpha');
        set(ll2,'linewidth',0.5);
        title(['Unit #: ', num2str(ind)]);
        xaxis_plt = 50:50:300;
        set(gca, 'xtick',xaxis_plt);
        xlabel('body speed (mm/s)')
        ylabel('firing rate (Hz)')
        if load_data_id ==1
            ylim([0,28]);
            set(gca, 'ytick',0:5:25);
        elseif load_data_id ==2
            ylim([8,32]);
        elseif load_data_id == 3
            ylim([18,30]);
            set(gca, 'ytick',20:5:30);
        elseif load_data_id == 4
            ylim([5,22]);
            set(gca, 'ytick',0:5:20);
        end
        title(load_data_from);
        xlim([xaxis_analysis(1),xaxis_analysis(end)]);
        set(gcf,'Position',[scrsz(1)+500 0.4*scrsz(2)+50 ...
                    0.2*scrsz(3) 0.3*scrsz(4)])   
        end
end
set(gcf,'Position',[680 578 1156 230])   

