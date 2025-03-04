% This file plots the gait encoding summary for all the regions, namely
% vector lengths and number of neurons encoding gait phase. 
% Plots figure 5 c, d and e of the manuscript.

areaNames = {'mpfc','m1','dms','dls'};
X_area = categorical({'mPFC','M1','DMS','DLS'});
X_area = reordercats(X_area,{'mPFC','M1','DMS','DLS'});
lineWeight  =0.5;
fontSizeNew = 7;
nosqr = 0;
colormaps = [0,0,0;
             1,0,0;
             0.9290,0.6940,0.1250];
set(groot,'defaultAxesXTickLabelRotationMode','manual')
mkSize =18;
all_areaStats = {};
all_area_pct = [];
all_area_units = [];
all_area_vec_lens = [];
all_area_vec_erros = [];
all_area_vec_angles = [];
all_area_vec_angle_erros = [];
all_area_vec_angles_trials = {};
Region = [];
area_lens_test = [];
for ii = 1:length(areaNames)
    filename = fullfile('../data/phase_coding_stats',areaNames{ii});
    d = dir(fullfile(filename,'stats*.mat'));

    % find the last modified file
    [~,idx] = max([d.datenum]);

    tmp_filename = d(idx).name;

    load(fullfile(filename,tmp_filename));
    all_areaStats{ii} = stats;
    area_locked_pct = [length(stats.lf_locked_units),... 
                        length(stats.lr_locked_units),...
                        length(stats.rf_locked_units),...
                        length(stats.rr_locked_units),...
                        length(stats.total_locked_units)];
    all_area_pct = [all_area_pct;area_locked_pct];
    all_area_units = [all_area_units;stats.totalunits];
    
    this_area_lens = [stats.vectorlength_lf;stats.vectorlength_lr;...
                        stats.vectorlength_rf; stats.vectorlength_rr];

    area_lens_test = [area_lens_test,this_area_lens];
    Region = [Region, repmat(areaNames(ii),1,size(this_area_lens,2))];
    new_data = [];
    
    
    this_area_lens_mean  = mean(this_area_lens,2);
    this_area_lens_error = std(this_area_lens,1,2)/sqrt(stats.totalunits);
    all_area_vec_lens = [all_area_vec_lens,this_area_lens_mean];
    all_area_vec_erros = [all_area_vec_erros,this_area_lens_error];

    all_area_vec_angles_trials{ii} = [stats.preferred_angle_lf;...
                                    stats.preferred_angle_lr;...
                                    stats.preferred_angle_rf;...
                                    stats.preferred_angle_rr];

    [rdirect_lf,u_lf,l_lf] = circ_mean(stats.preferred_angle_lf,[],2);
    [std_lf,~] = circ_std(stats.preferred_angle_lf');
    
    [rdirect_lr,u_lr,l_lr] = circ_mean(stats.preferred_angle_lr,[],2);
    [std_lr,~] = circ_std(stats.preferred_angle_lr');
    
    [rdirect_rf,u_rf,l_rf] = circ_mean(stats.preferred_angle_rf,[],2);
    [std_rf,~] = circ_std(stats.preferred_angle_rf');
    
    [rdirect_rr,u_rr,l_rr] = circ_mean(stats.preferred_angle_rr,[],2);
    [std_rr,~] = circ_std(stats.preferred_angle_rr');
    this_model_mean = wrapTo360(rad2deg([rdirect_lf,...
                        rdirect_lr,rdirect_rf,rdirect_rr]))';
    this_model_error = wrapTo360(rad2deg([std_lf,...
                            std_lr,std_rf,std_rr]))';

    all_area_vec_angles = [all_area_vec_angles, this_model_mean];
    all_area_vec_angle_erros = [all_area_vec_angle_erros, ...
                                    this_model_error];
    
end

t = table(Region',area_lens_test(1,:)',area_lens_test(2,:)',...
    area_lens_test(3,:)',area_lens_test(4,:)',...
                'VariableNames',[{'Region'},{'LF','LR','RF','RR'}]);
xvals = 1:4;
Meas = table(xvals','VariableNames',{'limb'});

rm = fitrm(t,...
            'LF-RR~Region','WithinDesign',Meas,'WithinModel','limb');

ranovatbl = ranova(rm)
r2 = ranova(rm,'WithinModel','limb');
T1 = multcompare(rm,'Region','By','limb');
T2 = multcompare(rm,'limb','By','Region');

color_IDs = {'red', 'blue','green', 'magenta', 'black'};
alphas = [1,0.5,0.2];

%%

limb_order = {'LF','LR','RF','RR'};
X = categorical(limb_order);
X = reordercats(X,limb_order);
xvalues= (1:numel(X));

stats_save = {};
mult_comparison_save = {};
figure(51)
clf(51)
for kk = 1:length(areaNames)
subplot(1,4,kk)
h = ploterr(xvalues, all_area_vec_lens(:,kk), ...
            [], all_area_vec_erros(:,kk),'.');
hold on;
set([h(:)],  'color', colormaps(1, :),...
    'linewidth',lineWeight); % set a nice color for the lines
     
set(h(1), 'markersize', mkSize, 'marker','.',...
    'markeredgecolor',colormaps(1, :)); % make the marker open
ylabel('vector length')
title(areaNames{kk});
if kk==1
yticks(0:0.05:0.15)
ylim([0,0.15])
elseif (kk==2)|| (kk==4)
yticks(0:0.1:0.2)
ylim([0,0.2])
elseif (kk==3)
yticks(0:0.05:0.15)
ylim([0,0.15])
end
set(gca, 'Xlim',[xvalues(1)-0.5,xvalues(end) + 0.5],...
    'XTick',xvalues,...
    'XTickLabel',X)
stats  = all_areaStats{kk};
t = table(stats.vectorlength_lf',stats.vectorlength_lr', ...
                stats.vectorlength_rf',stats.vectorlength_rr',...
'VariableNames',limb_order);
Meas = table([1 2 3 4]','VariableNames',{'limb'});
rm = fitrm(t,'LF-RR~1','WithinDesign',Meas,'WithinModel','limb');
ranovatbl = ranova(rm);
stats_save{kk} = ranovatbl;
T1 = multcompare(rm,'limb');
T1 = T1([1:3,5,6,9],:);
T1.("limb_1") = X(T1.("limb_1"))';
T1.("limb_2") = X(T1.("limb_2"))';
mult_comparison_save{kk} = T1;
ylims_here = get(gca, 'ylim');
pp = 1;
    for tid1 = 1:(length(limb_order)-1)
        for tid2 = (tid1+1):length(limb_order)
            
            mysigstar(gca, [tid1 tid2], 0.1 +pp*0.01, ...
                T1.("pValue")(pp));
            pp = pp +1;
        end
    end

end
set(gcf,'Position',[174 520 1705 420])   

%%
avg_area_lens = mean(area_lens_test);
nids_all = {};
figure(40)
clf(40)
for ii = 1:length(areaNames)
    nids = find(contains(Region,areaNames{ii}));
    nids_all{ii} = nids;
    meanlens_this = mean(avg_area_lens(nids));
    SDlens_this = std(avg_area_lens(nids));
    xvalues= (1:numel(areaNames));

    h = ploterr(xvalues(ii), meanlens_this, ...
                    [], SDlens_this/sqrt(length(nids)), ...
                    '.');
    hold on;
    set([h(:)],  'color', colormaps(1, :),...
        'linewidth',lineWeight); 
    set(h(1), 'markersize', mkSize, 'marker','.',...
        'markeredgecolor',colormaps(1, :)); % make the marker open
end
SetFigBoxDefaults
ylims_here = get(gca, 'ylim');
ylim([0.03,0.2]);
yticks_here = get(gca,'YTick');
set(gca, 'YTick',0:0.1:0.2)
set(gca, 'Xlim',[xvalues(1)-0.5,xvalues(end) + 0.5],...
'XTick',xvalues,...
'XTickLabel',X_area);
ylabel('limb average vector length');
    
stats_save = {};
mult_comparison_save = {};
figure(41)
[this_stats, this_multcompare] = do_1way_anova(Region,avg_area_lens);
kk = 1;
figure(40);
for tid1 = 1:(length(areaNames)-1)
    for tid2 = (tid1+1):length(areaNames)
        
        mysigstar(gca, [tid1 tid2], 0.15 +kk*0.005, ...
                this_multcompare.("P-value")(kk));
        kk = kk + 1;
    end
end
set(gcf,'Position',[600 50 400 400])

%%
figure(41)
clf(41)
xvalues = 1:4;
b1 = bar(xvalues,(all_area_pct(:,5)*100)./all_area_units,0.6);
set(gca, 'Xlim',[xvalues(1)-0.5,xvalues(end) + 0.5],...
    'XTick',xvalues,...
    'XTickLabel',X_area)

ylabel('% of phase-locked cells')
yticks(0:20:100)
ylim([0,100])

b1.FaceColor = 'flat';
b1.CData = [0,0,0];
b1.EdgeColor = 'none';
ylims_here = get(gca, 'ylim');
hold on;
kk = 1;
for tid1 = 1:(length(areaNames)-1)
    for tid2 = (tid1+1):length(areaNames)
        

        [chisq, pvalue]= test_chisquare(all_area_pct(tid1,5),...
                    all_area_units(tid1),...
                    all_area_pct(tid2,5),...
                    all_area_units(tid2),'n');
        mysigstar(gca, [tid1 tid2], 80 + kk*2, pvalue*6);
        
        kk = kk +1;
    end
end
set(gcf,'Position',[300 50 400 400])   