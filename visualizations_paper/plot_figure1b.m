% Plot areawise speed, acceleration and firing rates. This function normalizes the firing
% rates for all cells for each area and plots them together. 
% Plots Figure 1b in the manuscript.
figure(1)
clf(1)

nnrns = [200];
brainArea = {'dms'};

colormaps = [0,0.4470,0.7410;
             0.8500,0.3250,0.0980;
             0.9290,0.6940,0.1250];
lineWeight = 0.5;
get_sessionID_all = [3];
fontSizeNew = 7;
nosqr = 0;
kk = 1;
nreps = 50;
all_area_start_rms = {};
all_area_start_sem = [];
all_area_stop_rms = {};
all_area_stop_sem = [];

all_area_start_accl = [];
all_area_start_acclsem = [];
all_area_stop_accl = [];
all_area_stop_acclsem = [];

all_units_strFR = [];
all_units_stpFR = [];

nareas= length(brainArea);
ll_all = [];
mm_all = [];
ylim_all = 210;
for jj = 1:nareas
    
    
    filename = fullfile('../data',...
        lower(brainArea{jj}));
    if exist(filename,'dir')

    d = dir(fullfile(filename,'data*.mat'));
    
    % find the last modified file
    [~,idx] = max([d.datenum]);
    
    % name of file
    tmp_filename = d(idx).name;
    load(fullfile(filename,tmp_filename));
    else
        error("File not found.")
    end
    this_area_start_rms = [];
    this_area_stop_rms = [];
    this_area_start_rms_sem = [];
    this_area_stop_rms_sem = [];
    
    this_area_start_accl = [];
    this_area_stop_accl = [];
    this_area_start_accl_sem = [];
    this_area_stop_accl_sem = [];
    for kk = 1:length(all_start_rms_vel)
        this_area_start_rms = [this_area_start_rms,...
                                mean(all_start_rms_vel{kk},2)];
        this_area_start_rms_sem = [this_area_start_rms_sem,...
                                std(all_start_rms_vel{kk},[],2)/sqrt(size(all_start_rms_vel{kk},2))];
        this_area_stop_rms = [this_area_stop_rms,...
                                mean(all_stop_rms_vel{kk},2)];
        this_area_stop_rms_sem = [this_area_stop_rms_sem,...
                                std(all_stop_rms_vel{kk},[],2)/sqrt(size(all_stop_rms_vel{kk},2))];
        this_area_start_accl = [this_area_start_accl,...
                                mean(all_start_accl{kk},2)];
        this_area_stop_accl = [this_area_stop_accl,...
                                mean(all_stop_accl{kk},2)];
        
        this_area_start_accl_sem = [this_area_start_accl_sem,...
                                std(all_start_accl{kk},[],2)/...
                                sqrt(size(all_start_accl{kk},2))];
        this_area_stop_accl_sem = [this_area_stop_accl_sem,...
                                std(all_stop_accl{kk},[],2)/...
                                sqrt(size(all_stop_accl{kk},2))];
        
    end
    xaxis_rms = 1:length(this_area_start_rms);
    mid_pt = ceil(length(xaxis_rms)/2);
    xaxis_rms = (xaxis_rms - xaxis_rms(mid_pt))/framerate;
    get_sessionID = get_sessionID_all(jj);
    meantmp1 = this_area_start_rms(:,get_sessionID);
    stdtmp1 = this_area_start_rms_sem(:,get_sessionID);
    all_area_start_rms{jj} = this_area_start_rms;
    % all_area_start_sem = [all_area_start_sem, stdtmp1];
    meantmp2 =this_area_stop_rms(:,get_sessionID);
    stdtmp2 = this_area_stop_rms_sem(:,get_sessionID);


    subplot(2,2,jj)

    [ll,~] = boundedline(xaxis_rms,...
            meantmp1, stdtmp1,...
            'cmap','k','alpha');
    set(ll,'linewidth',lineWeight);
    ll_all = [ll_all,ll];
    
    hold on;
    xaxis_plt = -1.2:0.4:1.2;
    yaxis_plt = 0:50:200;
    % xaxis_label = -0.8:0.8:0.8;
    
    set(gca, 'xtick',xaxis_plt,'ytick',yaxis_plt);
    xlim([xaxis_rms(1),xaxis_rms(end)])
    ylim([25,ylim_all])
    
    xlabel('time to start(s)')
    ylabel('body speed (mm/s)')
    title(brainArea{jj})
    SetFigBoxDefaults


    meantmp1 = this_area_start_accl(:,get_sessionID);
    stdtmp1 = this_area_start_accl_sem(:,get_sessionID);

    meantmp2 = this_area_stop_accl(:,get_sessionID);
    stdtmp2 = this_area_stop_accl_sem(:,get_sessionID);

    subplot(2,2,jj+2)

    [ll,~] = boundedline(xaxis_rms,...
            meantmp1, stdtmp1,...
            'cmap','k','alpha');
    set(ll,'linewidth',lineWeight);

    hold on
    set(gca, 'xtick',xaxis_plt,'ytick',-500:500:1500);
    xlim([xaxis_rms(1),xaxis_rms(end)])
    ylim([-600,1500])    
    xlabel('time to start (s)')
    ylabel('acceleration (mm/s^2)')
    title(brainArea{jj})
    % legend(ll_all,regexprep(brainArea, '_', '\\_'),'Location','northwest')
    SetFigBoxDefaults
    
end


