% This file plots the percentage of neurons modulated in the start period of walking. 
% Plots figure 1f of the manuscript. 

nnrns = [200]; 
brainArea = {'Mpfc','M1', 'Dms','Dls'};
X = categorical({'mPFC','M1','DMS','DLS'});
X = reordercats(X,{'mPFC','M1','DMS','DLS'});
colormaps = [1,0,0;
             0,1,0;
             0,0,1;
             1,0,1];
lineWeight = 0.5;
fontSizeNew = 28;

kk = 1;
nreps = 50;
max_start_vl = zeros(length(brainArea)*length(nnrns),nreps);
max_stop_vl = zeros(length(brainArea)*length(nnrns),nreps);

% change the uniq_id to pick results from a new folder. 
uniq_id = 'Feb25'; 

ll_all = [];
mm_all = [];
first_mod_time_areawise = {};
pdf_areawise = {};
pdf_exc_inh_areawise = {}; % it will be calculated only near start for now. 
p_exc_inh = [];
pct_mod_areawise = zeros(length(brainArea),2);
take_all_modulated = 1;
sort_by_pos_neg = 1;
N_pos_neg_all = [];
n_mod_areas = zeros(length(brainArea),2);
ntotal_cells = [];
xaxis_here = -1:0.1:1;
for jj = 1:length(brainArea)
    

    filename = fullfile(fullfile('../data/latency_results/',...
        [brainArea{jj},'_results_',uniq_id,'_bsl_0.9_binSize_0.1']),...
        [num2str(nnrns(1)),'_nrns']);
    if exist(filename,'dir')
    filename = fullfile( filename,'all_plot_data.mat');
    load(filename)
    else
        error('File does not exist')
    end
    ncells_thisArea = length(sig_positive_cells.ind_modulated{1});
    ntotal_cells = [ntotal_cells, ncells_thisArea];
    for kk = 1:2
    
        subplot(3,3,(jj-1)*2+kk)
        this_cellIDs = sig_positive_cells.cellID{kk};
        this_first_modulated = sig_positive_cells.lookat{kk};
        this_first_modulated = this_first_modulated(this_cellIDs);
        this_all_modulated = sig_positive_cells.ind_modulated{kk};
        this_all_modulated = this_all_modulated(this_cellIDs);

        if take_all_modulated == 1
        neg_cellIDs = sig_negative_cells.cellID{kk};
        this_first_negmodulated = sig_negative_cells.lookat{kk};
        this_first_negmodulated = this_first_negmodulated(neg_cellIDs);
        this_all_negmodulated = sig_negative_cells.ind_modulated{kk};
        this_all_negmodulated = this_all_negmodulated(neg_cellIDs);
        this_cellIDs = [this_cellIDs,neg_cellIDs];
        this_first_modulated = [this_first_modulated,...
                                    this_first_negmodulated];
        this_all_modulated = [this_all_modulated,this_all_negmodulated];
                                    
        end
        all_first_mod_pts = zeros(length(this_cellIDs),1);
        pct_mod_areawise(jj,kk) = length(this_cellIDs)*100/ncells_thisArea;
        n_mod_areas(jj,kk) = length(this_cellIDs);
        for mm = 1:length(this_cellIDs)
            tmp1 = this_first_modulated{mm};
            tmp2 = this_all_modulated{mm};
            if kk==1
                all_first_mod_pts(mm,1) = tmp2(tmp1(1));
            else 
               all_first_mod_pts(mm,1) = tmp2(tmp1(end)+1);
            end
        end
        first_mod_time_areawise{jj,kk} = xaxis_analysis(all_first_mod_pts);
        if kk==1
        [~,sort_order_n] = sort(all_first_mod_pts);
        pdf_areawise{jj,kk} = get_pdf_ros(xaxis_here,...
                xaxis_analysis, this_all_modulated);
        else
            [~,sort_order_n] = sort(all_first_mod_pts,'descend');
           
        end
    end
end
%%
figure(1);
clf(1);
for jj = 1:length(brainArea)

    plot(xaxis_here,(pdf_areawise{jj,1}*100)/ntotal_cells(jj), ...
                '-','color',colormaps(jj,:),...
                'linewidth',lineWeight);
    % set(ll2,'linewidth',lineWeight);
    hold on
    
    % xaxis_plt = -1:0.5:1;
    xaxis_plt = -0.8:0.4:0.8;
    % ylim_all = 0.63;
    % 
    % ylim([0,ylim_all])
    xlim([xaxis_here(1),xaxis_here(end)])
    xlabel('time to start (s)')
    ylabel('% of modulated neurons')
    
    set(gca, 'xtick',xaxis_plt,'YTick',0:10:50);   
    SetFigBoxDefaults
end
legend(regexprep(string(X), '_', '\\_'),'Location','northwest')
