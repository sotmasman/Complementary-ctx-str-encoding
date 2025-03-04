% Calculates the mean rate of data using spiketimes and stimulus times. 
function [meanrate, SEMrate, timebins] = plot_meanrate_noplot(stimulustimes, spiketimes, binduration, tmin, tmax, moving_avg_span)
  
if size(spiketimes,1)<size(spiketimes,2)
  spiketimes = spiketimes';
end

ntrials=length(stimulustimes);

timebins=[tmin:binduration:(tmax+binduration)];

spikespertrial=zeros(ntrials, length(timebins));

for trial=1:ntrials;
    
    trialtime=stimulustimes(trial); 
    
    spikeinds=find(spiketimes<(trialtime+max(timebins)) & spiketimes>(trialtime+min(timebins)));
    
    relative_spiketimes=spiketimes(spikeinds)-trialtime;

    [n,bins]=histc(relative_spiketimes, timebins);	
    
    c = moving_average(n, timebins, moving_avg_span, 'n');
	
    spikespertrial(trial,:)= c;
         
end

meanrate = mean(spikespertrial)/binduration;

SEMrate = std(spikespertrial)/sqrt(ntrials)/binduration;

timebins(end)=[];
meanrate(end)=[];
SEMrate(end)=[];
