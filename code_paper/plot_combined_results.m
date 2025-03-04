% plots different graphs based on the options set. 
function plot_combined_results(plotFunction, varargin)

options = struct('speedAndacceleration', false,...
                    'spread', false,...
                    'meanFR', false,...
                    'FRstacks',false,...
                    'accrStacks',false,...
                    'phaseaccrStacks',false,...
                    'lickaccrStacks', false,...
                    'limbName','LF',...
                    'start_rms', [] , ...
                    'stop_rms', [], ...
                    'start_accl', [], ...
                    'stop_accl', [], ...
                    'xaxis_rms', [], ...
                    'start_spread', [],...
                    'stop_spread', [],...
                    'xaxis_analysis', [],...
                    'startFR', [],...
                    'stopFR', [],...
                    'startaccrs',[],...
                    'stopaccrs',[],...
                    'phaseaccrs',[],...
                    'lickaccrs',[]);
subplot_vals = [2,3,4,5,6,7,8];

optionNames = fieldnames(options);
for pair = reshape(varargin, 2, [])
    if any(strcmp(pair{1}, optionNames))
        options.(pair{1}) = pair{2};
    else
        error('%s is not a recognized parameter name', pair{1});
    end
end
subplot_vals = [0,2];
if (options.speedAndacceleration)
    subplot_vals(1) = subplot_vals(1) + 1;
    
    % subplot_vals(2) = subplot_vals(2) + 2;
    
end
if (options.spread)
    subplot_vals(1) = subplot_vals(1) + 1;
    % subplot_vals(2) = subplot_vals(2) + 2;
end
if options.meanFR
    subplot_vals(1) = subplot_vals(1) + 1;
    % subplot_vals(2) = subplot_vals(2) + 2;
end

if options.FRstacks
    subplot_vals(1) = subplot_vals(1) + 1;
end
if options.accrStacks
    subplot_vals(1) = subplot_vals(1) + 1;
end

if options.phaseaccrStacks
    subplot_vals(1) = subplot_vals(1) + 1;
end

if options.lickaccrStacks
    subplot_vals(1) = subplot_vals(1) + 1;
end


subplots_done = 1;
if (options.speedAndacceleration)

xaxis_speed = options.xaxis_rms;
all_start_rms_vel = options.start_rms;
all_stop_rms_vel = options.stop_rms;
all_start_accl = options.start_accl;
all_stop_accl = options.stop_accl;
n_ses = length(all_start_rms_vel);
clrs = jet(n_ses);
yspan = [];
dashtypes = {'-','--'};
deflt_colr_type = 'k';
subplots_here = [subplots_done,subplots_done+1];
for i = 1:n_ses
    mean_start_rms_vel = mean(all_start_rms_vel{i},2);
    mean_start_accl = mean(all_start_accl{i},2);
    xline_x = zeros(1,length(mean_start_rms_vel));
    xline_y = 1:1:length(mean_start_rms_vel);
    subplot(subplot_vals(1),subplot_vals(2),subplots_here(1)) % line to be changed

    yyaxis left

    plotFunction(mean_start_rms_vel,xaxis_speed,...
        yspan,clrs(i,:),dashtypes{1});
    hold on
    plotFunction(xline_y,xline_x,yspan, deflt_colr_type,dashtypes{2});
    yyaxis right
    plotFunction(mean_start_accl, xaxis_speed,...
        yspan,clrs(i,:), dashtypes{2});

    mean_stop_rms_vel = mean(all_stop_rms_vel{i},subplots_here(2));
    
    mean_stop_accl = mean(all_stop_accl{i},2);
    subplot(subplot_vals(1),subplot_vals(2),2) % line to be changed
    yyaxis left
    plotFunction(mean_stop_rms_vel,xaxis_speed,...
        yspan,clrs(i,:),dashtypes{1});
    hold on
    plotFunction(xline_y,xline_x,yspan, deflt_colr_type,dashtypes{2});
    yyaxis right
    plotFunction(mean_stop_accl, xaxis_speed,...
        yspan,clrs(i,:), dashtypes{2});
end
strend = {'start','end'};
kk =1; 
for ii = subplots_here
    subplot(subplot_vals(1),subplot_vals(2),ii)
    xlabel(['time to walk ',strend{kk},' (s)']);
    kk = kk +1;
    yyaxis left
    ylabel(['rms velocity'])
    yyaxis right
    ylabel(['acceleration'])
end
subplots_done = subplots_done + 2;


end

if (options.spread)
    xaxis_speed = options.xaxis_rms;
    all_start_spread = options.start_spread;
    all_stop_spread = options.stop_spread;
    n_ses = length(all_start_spread);
    clrs = jet(n_ses);
    yspan = [];
    dashtypes = {'-','--'};
    deflt_colr_type = 'k';
    subplots_here = [subplots_done,subplots_done+1];

    for i = 1:n_ses
    mean_start_spread = mean(all_start_spread{i},2);
    subplot(subplot_vals(1),subplot_vals(2),subplots_here(1)) % line to be changed

    plotFunction(mean_start_spread,xaxis_speed,...
        yspan,clrs(i,:),dashtypes{1});
    hold on
    max_sprd = max(mean_start_spread)+5;
    min_sprd = min(mean_start_spread)-5;
    xline_y = min_sprd:(max_sprd-min_sprd)/(length(mean_start_spread)-1):max_sprd;
    xline_x = zeros(1,length(mean_start_spread));
    plotFunction(xline_y,xline_x,yspan, deflt_colr_type,dashtypes{2});
    
    mean_stop_spread = mean(all_stop_spread{i},2);
    subplot(subplot_vals(1),subplot_vals(2),subplots_here(2)) % line to be changed

    plotFunction(mean_stop_spread,xaxis_speed,...
        yspan,clrs(i,:),dashtypes{1});
    hold on
    plotFunction(xline_y,xline_x,yspan, deflt_colr_type,dashtypes{2});
    end
    strend = {'start','end'};
    kk =1; 
    for ii = subplots_here
        subplot(subplot_vals(1),subplot_vals(2),ii)
        xlabel(['time to walk ',strend{kk},' (s)']);
        kk = kk +1;
        
        ylabel(['spread (mm)'])
    end
    subplots_done = subplots_done + 2;
end

if options.meanFR
    xaxis_speed = options.xaxis_analysis;
    all_units_mean_str = options.startFR;
    all_units_mean_stp = options.stopFR;
    n_units_now = size(all_units_mean_str,2);
    
    subplots_here = [subplots_done,subplots_done+1];

    meanstartrate = mean(all_units_mean_str,2);
    SDstartrate = std(all_units_mean_str,[],2);
    meanstoprate = mean(all_units_mean_stp,2);
    SDstoprate = std(all_units_mean_stp,[],2);
    subplot(subplot_vals(1),subplot_vals(2),subplots_here(1))
    boundedline(xaxis_speed,...
                meanstartrate, SDstartrate/sqrt(n_units_now), 'b')
    subplot(subplot_vals(1),subplot_vals(2),subplots_here(2))

    boundedline(xaxis_speed,...
                    meanstoprate, SDstoprate/sqrt(n_units_now), 'r')
    
    strend = {'start','end'};
    kk =1; 
    for ii = subplots_here
        subplot(subplot_vals(1),subplot_vals(2),ii)
        xlabel(['time to walk ',strend{kk},' (s)']);
        kk = kk +1;
        ylabel(['mean FR (Hz)'])
    end
    subplots_done = subplots_done + 2;
end

if options.FRstacks
    xaxis_speed = options.xaxis_analysis;
    all_units_mean_str = options.startFR;
    all_units_mean_stp = options.stopFR;
    yspan = [];
    subplots_here = [subplots_done,subplots_done+1];

    subplot(subplot_vals(1),subplot_vals(2),subplots_here(1))
    plotFunction(all_units_mean_str,xaxis_speed,...
        yspan,[],[],'plotstack',true);
    subplot(subplot_vals(1),subplot_vals(2),subplots_here(2))
    plotFunction(all_units_mean_stp,xaxis_speed,...
        yspan,[],[],'plotstack',true);
    colormap('default')

    strend = {'start','end'};
    kk =1; 
    for ii = subplots_here
        subplot(subplot_vals(1),subplot_vals(2),ii)
        xlabel(['time to walk ',strend{kk},' (s)'])
        ylabel('ordered cell #')
        % set(gca,'Xlim',[0,total_bins]+(bin_size_val*total_bins/2))
        set(gca,'XTick',[1:size(all_units_mean_str,1)])  %note: plot limits are different from plot_unitstack. 
        set(gca,'XTickLabel',  xaxis_speed)
        kk = kk +1;
        SetFigBoxDefaults
        
    end
    subplots_done = subplots_done + 2;
    
end

if options.accrStacks
    xaxis_speed = options.xaxis_analysis;
    start_accrs = options.startaccrs;
    stop_accrs = options.stopaccrs;
    yspan = [];
    subplots_here = [subplots_done,subplots_done+1];
    
    meanstartaccr = mean(start_accrs);
    SDstartaccr = std(start_accrs,[],1);
    meanstopaccr = mean(stop_accrs);
    SDstopaccr = std(stop_accrs,[],1);
    n_nrn_draws = size(start_accrs,1);
    subplot(subplot_vals(1),subplot_vals(2),subplots_here(1))
    
    boundedline(xaxis_speed,...
                meanstartaccr, SDstartaccr/sqrt(n_nrn_draws), 'b')
    
    subplot(subplot_vals(1),subplot_vals(2),subplots_here(2))
    boundedline(xaxis_speed,...
                    meanstopaccr, SDstopaccr/sqrt(n_nrn_draws), 'r')

    strend = {'start','end'};
    kk =1; 
    for ii = subplots_here
        subplot(subplot_vals(1),subplot_vals(2),ii)
        ylim([0,1])
        xlim([xaxis_speed(1),xaxis_speed(end)])
        xlabel(['time to walk ',strend{kk},' (s)'])
        ylabel('mean accuracy')
        kk = kk+1;
        SetFigBoxDefaults
    end
    subplots_done = subplots_done + 2;
end

if options.phaseaccrStacks
    xaxis_phase = options.xaxis_analysis;
    phase_accrs = options.phaseaccrs;
    
    yspan = [];
    subplots_here = [subplots_done];
    
    meanphaseaccr = mean(phase_accrs);
    SDphaseaccr = std(phase_accrs,[],1);
    
    n_nrn_draws = size(phase_accrs,1);
    subplot(subplot_vals(1),subplot_vals(2),subplots_here(1))
    tmp = (xaxis_phase(1:(end-1)) +xaxis_phase(2:end))/2;
    boundedline(tmp,...
                meanphaseaccr, SDphaseaccr/sqrt(n_nrn_draws), 'b')

    strend = {'start','end'};
    kk =1; 
    
    subplot(subplot_vals(1),subplot_vals(2),subplots_here(end))
    ylim([0,1])
    xlim([xaxis_phase(1),xaxis_phase(end)])
    xticks(xaxis_phase(1:4:end))
    xlabel([options.limbName,' Phase (deg)'])
    ylabel('mean accuracy')
    kk = kk+1;
    SetFigBoxDefaults
    
    subplots_done = subplots_done + 1;
end
set(gcf,'Position',[2000   141   837   250*subplot_vals(1)]) 


if options.lickaccrStacks
    xaxis_analysis = options.xaxis_analysis;
    lick_accrs = options.lickaccrs;
    
    yspan = [];
    subplots_here = [subplots_done];
    
    meanphaseaccr = mean(lick_accrs);
    SDphaseaccr = std(lick_accrs,[],1);
    
    n_nrn_draws = size(lick_accrs,1);
    subplot(subplot_vals(1),subplot_vals(2),subplots_here(1))
    % tmp = (xaxis_phase(1:(end-1)) +xaxis_phase(2:end))/2;
    boundedline(xaxis_analysis,...
                meanphaseaccr, SDphaseaccr/sqrt(n_nrn_draws), 'b')

    kk =1; 
    
    subplot(subplot_vals(1),subplot_vals(2),subplots_here(end))
    ylim([0,1])
    xlim([xaxis_analysis(1),xaxis_analysis(end)])
    xticks(xaxis_analysis(1:4:end))
    xlabel(['Time to first lick (s)'])
    ylabel('mean accuracy')
    kk = kk+1;
    SetFigBoxDefaults
    
    subplots_done = subplots_done + 1;
end
set(gcf,'Position',[2000   141   837   250*subplot_vals(1)]) 
