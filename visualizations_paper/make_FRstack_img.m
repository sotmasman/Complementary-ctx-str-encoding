% this function plots the stacks for firing rates of multiple neurons. 
function make_FRstack_img(scr_all_units_str,xaxis_analysis,plot_max,plot_zscored)
setFigDefaults_anneu

% choosing a good colormap is especially important for diverging data, that
% is, data that is centred at zero and has minima and maxima below and
% above. cbrewer has a range of nice colormaps.

colors = cbrewer('seq', 'YlOrRd', 64);


% colors = cbrewer('seq', 'YlOrRd', 64);
colors = flipud(colors); % puts red on top, blue at the bottom
colormap(colors);

% when the data are sequential (eg. only going from 0 to positive, use for
% example colors = cbrewer('seq', 'YlOrRd', 64); or the default parula.

if plot_zscored == 1
    imagesc(scr_all_units_str,[-1.5,plot_max]);
else
    plot_max = 0.9;
    imagesc(scr_all_units_str,[0,plot_max]);
end
% note that imagesc cannot handle unevenly spaced axes. if you want eg. a
% logarithmically scaled colormap, see uimagesc.m from the file exchange
% (also included in fieldtrip)

% imagesc automatically flips the y-axis so that the smallest values go on
% top. Set this right if we want the origin to be in the left bottom
% corner.
set(gca, 'ydir', 'normal');
% axis square;

handles = colorbar;
handles.TickDirection = 'out';
if plot_zscored == 1
    handles.Ticks = [-1.5,plot_max];
else
    handles.Ticks = 0:0.2:plot_max;
end
handles.Box = 'off';
handles.LineWidth = 0.5;
handles.TickLength = 0.02;
handles.TickDirection = 'out';
drawnow;


axpos = get(gca, 'Position');
cpos = handles.Position;
cpos(3) = 0.5*cpos(3);
handles.Position = cpos;
drawnow;

% restore axis pos
set(gca, 'position', axpos);
drawnow;

xlabel('predicted time (s)'); ylabel('actual time (s)');
len_xaxi = length(xaxis_analysis);

set(gca, 'xtick',4:4:len_xaxi,...
        'ytick',0:50:200,...
        'XTickLabel',xaxis_analysis(4:4:len_xaxi));
end
