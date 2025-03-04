% It can plot the raster of a neuron aligned to the stance times of a
% walking cycle. 
function plotraster_gait(stimulustimes, spiketimes, tmin, tmax, plotstyle)

numberoftrials=length(stimulustimes);

tbins=[tmin:0.0001:tmax];

rasterx=[];
rastery=[];

set(gcf, 'renderer', 'Painters')

for trial=1:numberoftrials;
    
    trialtime=stimulustimes(trial); 
    
    spikeinds=find(spiketimes<(trialtime+tmax) & spiketimes>(trialtime+tmin));
    
    relative_spiketimes=spiketimes(spikeinds)-trialtime;

    [n,bins]=histc(relative_spiketimes, tbins);	

    rasterx=[rasterx tbins(bins)];
    rastery=[rastery trial*ones(1,sum(n))];
    
    if strcmp(plotstyle, 'lines')
    plot([relative_spiketimes;relative_spiketimes],[0.95*ones(size(relative_spiketimes))+(trial-0.4); zeros(size(relative_spiketimes))+(trial-0.4)],'k', 'LineWidth', 1)
    hold on
    end
         
end

if strcmp(plotstyle, 'dots')
scatter(rasterx, rastery, 0.1, 'k', 'o', 'MarkerFaceColor', 'k')
end

