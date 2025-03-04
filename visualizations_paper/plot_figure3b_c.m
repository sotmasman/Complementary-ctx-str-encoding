% This file plots the R2 for firing rate and speed and also calculated the
% percentage of units that are significantly modulated by speed. 
% Plots figure 3 b and c of the manuscript. 

figure(1)
clf(1)
addpath(genpath('../'))

nnrns = [200]; 
brainArea = {'Mpfc','M1','Dms','Dls'};
X = categorical({'mPFC','M1','DMS','DLS'});
X = reordercats(X,{'mPFC','M1','DMS','DLS'});
load_data_order = [3,2,1,6];
colormaps = [0,0,0;
             1,0,0;
             0,1,0;
             0,0,1];

lineWeight  =0.5;
fontSizeNew = 7;
nosqr = 0;
mkSize = 36;
set(groot,'defaultAxesXTickLabelRotationMode','manual')

save_for_manscrpt = 1;
speed_coding_all = [];
Rsq_all = {};
total_cells_all = [];
for jj = 1:length(brainArea)
    load_data_id = load_data_order(jj);
    [speed_code_cells,real_Rsq, ntotal] = plot_speedwise_rates(200,load_data_id);
    speed_coding_all = [speed_coding_all, sum(speed_code_cells)];
    total_cells_all = [total_cells_all,ntotal];
    Rsq_all{jj} = real_Rsq;
end

%%

figure(1)
clf(1)
xvalues = 1:4;
b1 = bar(xvalues,(speed_coding_all*100)./total_cells_all,0.6);

set(gca, 'Xlim',[xvalues(1)-0.5,xvalues(end) + 0.5],...
    'XTick',xvalues,...
    'XTickLabel',X)
ylims_here = get(gca, 'ylim');
hold on;
kk = 1;
for tid1 = 1:(length(brainArea)-1)
    for tid2 = (tid1+1):length(brainArea)
        

        [chisq, pvalue]= test_chisquare(speed_coding_all(tid1),...
                    total_cells_all(tid1),...
                    speed_coding_all(tid2),...
                    total_cells_all(tid2),'n');
        mysigstar(gca, [tid1 tid2], max(abs(ylims_here))-5 + kk*2, pvalue*6);
        
        kk = kk +1;
    end
end

b1.FaceColor = 'flat';
b1.CData = [0,0,0];

b1.EdgeColor = 'none';

ylim([0,80])

set(gca,'YTick',0:20:80);

ylabel('% of speed correlated cells')
set(gcf,'Position',[366 277 332 332])   

%%
figure(2)
clf(2)
compid = 1;
stats_save = {};
mult_comparison_save = {};
thisReg = {};
this_tmp = Rsq_all;
this_comp = [];
for arid = 1:length(brainArea)
    all_area_tmp = this_tmp{arid};
    thisReg = [thisReg,repelem({char(X(arid))},1,length(all_area_tmp))];
    this_comp = [this_comp,all_area_tmp];
end

[this_stats, this_multcompare] = do_1way_anova(thisReg,this_comp);
stats_save{compid} = this_stats;
mult_comparison_save{compid} = this_multcompare;

figure(2)
clf(2)

nosqr = 0;
for ptid = 1
    subplot_tr = [ 1,1,ptid];
    subplot(subplot_tr(1),subplot_tr(2),subplot_tr(3))
    meanprestartaccr = cellfun(@mean,Rsq_all);
    SDprestartaccr = cellfun(@std,Rsq_all);
    xvalues= (1:numel(X));
    
    h = ploterr(xvalues, meanprestartaccr, ...
                    [], SDprestartaccr./sqrt(total_cells_all), ...
                    '.');

    hold on;
    set([h(:)],  'color', colormaps(1, :),...
    'linewidth',lineWeight); % set a nice color for the lines
    % how does the marker look?
    set(h(1), 'markersize', mkSize, 'marker','.',...
        'markeredgecolor',colormaps(1, :)); % make the marker open
    
    ylims_here = get(gca, 'ylim');
    
    yticks_here = get(gca,'YTick');

    set(gca, 'YTick',0.3:0.1:0.5)
    ylim([0.3,0.55]);
    set(gca, 'Xlim',[xvalues(1)-0.5,xvalues(end) + 0.5],...
    'XTick',xvalues,...
    'XTickLabel',X)
    % xlabel('# of units')
    ylabel('R^2');
    SetFigBoxDefaults
    set(gcf,'Position',[600 50 1200 1200])   
        
    mutl_tmp = mult_comparison_save{ptid};
    kk = 1;
    for tid1 = 1:(length(brainArea)-1)
        for tid2 = (tid1+1):length(brainArea)
            mysigstar(gca, [tid1 tid2], max(abs(ylims_here)) +kk*0.01, ...
                mutl_tmp.("P-value")(kk));
            kk = kk +1;
        end
    end

end
set(gcf,'Position',[166 277 332 332])   

