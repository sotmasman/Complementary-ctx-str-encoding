% This file plots a walking bout and the corresponding trajectories of the
% four limbs.
% Plots Figure 4b of the manuscript. 

addpath(genpath('../'))
nnrns = [200]; 
brainArea = {'M1'};

colors = cbrewer('seq', 'Greys', 8);
colors = flipud(colors);
fontSizeNew = 7;
nosqr = 1;
lineWeight = 0.5;
get_sessionID = 8;
around_time = 3;
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
off_amount =200;
figure(1);
clf(1);

for jj = 1:1
    
    
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

    this_walk_perds = walk_prd_for_decd_all_ses{get_sessionID};
    this_marker_pos = marker_pos_all_ses{get_sessionID};
    this_rms_vel = rms_speed_all_ses{get_sessionID};
    this_limb_phase = limb_phase_all_ses{get_sessionID}*180/pi;
    ndurs_this_ses = (this_walk_perds.stopframes -...
                    this_walk_perds.startframes+1)/framerate;
    places = find((ndurs_this_ses>2.5));

    places = [41]; 
    figure(1);
    rotate_limb_coords_here
    this_ses_strides = strides.lr_stance_start_inrange{get_sessionID}*80;
    for kk = 1:length(places)
        subplot(2,1,1);
        startfr = this_walk_perds.startframes(places(kk)) ...
                        - double(framerate*around_time);
        endfr = this_walk_perds.stopframes(places(kk)) ...
                    + double(framerate*around_time);
        pt_x1 = double(framerate*around_time) + 1;
        
        this_walk_rms = this_rms_vel(startfr:endfr);
        pt_x2 = length(this_walk_rms) - double(framerate*around_time);
        plot(1:length(this_walk_rms),this_walk_rms +(kk-1)*off_amount,...
            'color',colors(kk,:),...
              'linewidth',lineWeight);
        hold on;
        
        plot([pt_x1,pt_x1],[(kk-1),kk]*off_amount,'--g','linewidth',lineWeight);
        plot([pt_x2,pt_x2],[(kk-1),kk]*off_amount,'--r',...
            'linewidth',lineWeight);
        plot(  [9;88], [250;250], '-k', 'LineWidth', lineWeight)
    
    
        temp_frames = this_walk_perds.startframes(places(kk)):this_walk_perds.stopframes(places(kk));
        
        this_walk_stance_start = find((this_ses_strides>=temp_frames(1))&...
                                       (this_ses_strides<=temp_frames(end)));
        stance_frames = this_ses_strides(this_walk_stance_start);
        subplot(2,1,2);            
        plot(filt_nlf(temp_frames), 'r', 'LineWidth', lineWeight)
        hold on
        plot(filt_nlr(temp_frames), 'g', 'LineWidth', lineWeight)
        scatter(stance_frames-temp_frames(1)+1,...
            filt_nlr(stance_frames),36,'g',"filled")
        plot(filt_nrf(temp_frames), 'b', 'LineWidth', lineWeight)
        plot(filt_nrr(temp_frames), 'm', 'LineWidth', lineWeight)
        plot(  [9;88], [-18;-18], '-k', 'LineWidth', lineWeight)
        
    end
    subplot(2,1,1);
    yticks([0,300])
    ylabel('body speed (mm/s)')
    h = gca;
    h.XAxis.Visible = 'off';
    ylim([-10,350])

    subplot(2,1,2);
    ylabel('limb position (mm)')
    
    h = gca;
    h.XAxis.Visible = 'off';

end



