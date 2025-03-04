% This function makes the confusion matrice for the predicted and actual
% labels in a nice color scheme. 
function make_confusion_img(confMat_str,timeArea,xaxis_analysis,varargin)
setFigDefaults_anneu

% choosing a good colormap is especially important for diverging data, that
% is, data that is centred at zero and has minima and maxima below and
% above. cbrewer has a range of nice colormaps.
% colors = cbrewer('div', 'RdBu', 64);
colors = cbrewer('seq', 'Greys', 64);
% colors = cbrewer('seq', 'YlOrRd', 64);
colors = flipud(colors); % puts red on top, blue at the bottom
colormap(colors);

if length(varargin)>0
    max_clr_val = varargin{1};
else
    max_clr_val = 0.5;
end
% when the data are sequential (eg. only going from 0 to positive, use for
% example colors = cbrewer('seq', 'YlOrRd', 64); or the default parula.

max_N = sum(confMat_str(1,:));
z = confMat_str/max_N;
imagesc(z,[0,max_clr_val]);

% note that imagesc cannot handle unevenly spaced axes. if you want eg. a
% logarithmically scaled colormap, see uimagesc.m from the file exchange
% (also included in fieldtrip)

% imagesc automatically flips the y-axis so that the smallest values go on
% top. Set this right if we want the origin to be in the left bottom
% corner.
% set(gca, 'ydir', 'normal');
axis square;

handles = colorbar;
handles.TickDirection = 'out';
handles.Ticks = 0:0.1:0.5;
handles.Box = 'off';
handles.LineWidth = 0.5;
handles.TickLength = 0.02;
handles.TickDirection = 'out';
handles.Label.String = 'decoding probability';
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

set(gca, 'xtick',2:2:len_xaxi,...
        'ytick',2:2:len_xaxi,...
        'XTickLabel',xaxis_analysis(2:2:len_xaxi),...
        'YTickLabel', xaxis_analysis(2:2:len_xaxi));
end
