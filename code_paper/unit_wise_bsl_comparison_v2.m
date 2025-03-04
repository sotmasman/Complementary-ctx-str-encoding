total_bins = size(unit_wise_walk_fRates{n_units_now,2},2);

xaxis_analysis = [1:total_bins]*bin_size_val - (bin_size_val*(total_bins+1)/2);

baseline_bins_str = find((xaxis_analysis>=baseline_period(1))& ...
                    (xaxis_analysis<=baseline_period(2)));
baseline_bins_stp = find((xaxis_analysis>=-baseline_period(2))& ...
                    (xaxis_analysis<=-baseline_period(1)));

all_units_mean_baseline_str = zeros(length(baseline_bins_str),n_units_now);
all_units_mean_baseline_stp = zeros(length(baseline_bins_stp),n_units_now);
all_units_baseline_str = {};
all_units_baseline_stp = {};
all_units_mean_str = zeros(total_bins, n_units_now);
all_units_sem_str = zeros(total_bins, n_units_now);

all_units_mean_stp = zeros(total_bins, n_units_now);
all_units_sem_stp = zeros(total_bins,n_units_now);

max_fr_bin_str = zeros(n_units_now,1);
max_fr_bin_stp = zeros(n_units_now,1);
signif_level = 0.05;
for kk = 1:n_units_now
    tmp1 = unit_wise_walk_fRates{kk,1};
    mean_fr_str = mean(unit_wise_walk_fRates{kk,1});
    ntr = size(unit_wise_walk_fRates{kk,1},1);
    sem_fr_str = std(unit_wise_walk_fRates{kk,1},[],1)./sqrt(ntr);
    
    tmp1 = tmp1(:,baseline_bins_str);
    tmp1 = mean(tmp1,2);
    all_units_baseline_str{kk} = tmp1;

    
    tmp1 = unit_wise_walk_fRates{kk,2};
    mean_fr_stp = mean(unit_wise_walk_fRates{kk,2});
    ntr = size(unit_wise_walk_fRates{kk,2},1);
    sem_fr_stp = std(unit_wise_walk_fRates{kk,2},[],1)./sqrt(ntr);
    
    tmp1 = tmp1(:,baseline_bins_stp);
    tmp1 = mean(tmp1,2);
    all_units_baseline_stp{kk} = tmp1;


    all_units_mean_str(:,kk) = mean_fr_str;
    all_units_sem_str(:,kk) = sem_fr_str;
    
    
    this_bs = mean_fr_str(baseline_bins_str);
    all_units_mean_baseline_str(:,kk) = this_bs;
    [~,ind_max] = max(mean_fr_str);
    max_fr_bin_str(kk) = ind_max;

    all_units_mean_stp(:,kk) = mean_fr_stp;
    all_units_sem_stp(:,kk) = sem_fr_stp;
    this_bs = mean_fr_stp(baseline_bins_stp);
    all_units_mean_baseline_stp(:,kk) = this_bs;
    [~,ind_max] = max(mean_fr_stp);
    max_fr_bin_stp(kk) = ind_max;
end

sig_positive_cells.cellID = cell(1,2);
sig_negative_cells.cellID = cell(1,2);

sig_positive_cells.ind_modulated = cell(1,2);
sig_negative_cells.ind_modulated = cell(1,2);

sig_positive_cells.lookat = cell(1,2);
sig_negative_cells.lookat = cell(1,2);
devit_amt = 2;
all_mod_psstr = [];
all_mod_psstp = [];
all_mod_ngstr = [];
all_mod_ngstp = [];

bins_psstr = cell(1,n_units_now);
bins_psstp = cell(1,n_units_now);
bins_ngstr = cell(1,n_units_now);
bins_ngstp = cell(1,n_units_now);

first_bin_psstr = cell(1,n_units_now);
last_bin_psstp = cell(1,n_units_now);
first_bin_ngstr = cell(1,n_units_now);
last_bin_ngstp = cell(1,n_units_now);
for kk = 1:n_units_now
    %% for start case
    this_mean_str = all_units_mean_str(:,kk);
    tmp1 = unit_wise_walk_fRates{kk,1};
    this_bsl = all_units_baseline_str{kk};
    this_mean_bsl = mean(all_units_mean_baseline_str(:,kk));
    this_pvals = ones(1,total_bins);
    for ll = baseline_bins_str(1):total_bins
        [~,this_pvals(ll)] = ttest(this_bsl,tmp1(:,ll));
        
    end
    pos_modulated_ros = find((this_pvals<signif_level) & (this_mean_str'>this_mean_bsl));
    neg_modulated_ros = find((this_pvals<signif_level) & (this_mean_str'<this_mean_bsl));
    
    if (~isempty(pos_modulated_ros))
        if (pos_modulated_ros(1)>baseline_bins_str(end))
            consec_ros = find(diff(pos_modulated_ros)==1);
            if (~isempty(consec_ros))
                all_mod_psstr = [all_mod_psstr,kk];
                bins_psstr{kk} = pos_modulated_ros;
                first_bin_psstr{kk} = consec_ros;
            end
        end
    else
        if (~isempty(neg_modulated_ros))
            if (neg_modulated_ros(1)>baseline_bins_str(end))
                consec_ros = find(diff(neg_modulated_ros)==1);

                if (~isempty(consec_ros))
                    all_mod_ngstr = [all_mod_ngstr,kk];
                    bins_ngstr{kk} = neg_modulated_ros;
                    first_bin_ngstr{kk} = consec_ros;
                end
            end
        end
    end
    %% for stop case
    this_mean_stp = all_units_mean_stp(:,kk);
    tmp1 = unit_wise_walk_fRates{kk,2};
    this_bsl = all_units_baseline_stp{kk};
    this_mean_bsl = mean(all_units_mean_baseline_stp(:,kk));
    this_pvals = ones(1,total_bins);
    for ll = 1:baseline_bins_stp(end)
        [~,this_pvals(ll)] = ttest(this_bsl,tmp1(:,ll));
        
    end
    pos_modulated_ros = find((this_pvals<signif_level) & (this_mean_stp'>this_mean_bsl));
    neg_modulated_ros = find((this_pvals<signif_level) & (this_mean_stp'<this_mean_bsl));
    
    if (~isempty(pos_modulated_ros))
        if (pos_modulated_ros(end)<baseline_bins_stp(1))
            consec_ros = find(diff(pos_modulated_ros)==1);
            if (~isempty(consec_ros))
                all_mod_psstp = [all_mod_psstp,kk];
                bins_psstp{kk} = pos_modulated_ros;
                last_bin_psstp{kk} = consec_ros;
            end
        end
    else
        if (~isempty(neg_modulated_ros))
            if (neg_modulated_ros(end)<baseline_bins_stp(1))
                consec_ros = find(diff(neg_modulated_ros)==1);

                if (~isempty(consec_ros))
                    all_mod_ngstp = [all_mod_ngstp,kk];
                    bins_ngstp{kk} = neg_modulated_ros;
                    last_bin_ngstp{kk} = consec_ros;
                end
            end
        end
    end

    
end
sig_positive_cells.cellID{1} = all_mod_psstr;
sig_positive_cells.cellID{2} = all_mod_psstp;
sig_negative_cells.cellID{1} = all_mod_ngstr;
sig_negative_cells.cellID{2} = all_mod_ngstp;
sig_positive_cells.ind_modulated{1} = bins_psstr;
sig_positive_cells.ind_modulated{2} = bins_psstp;
sig_negative_cells.ind_modulated{1} = bins_ngstr;
sig_negative_cells.ind_modulated{2} = bins_ngstp;
sig_positive_cells.lookat{1} = first_bin_psstr;
sig_positive_cells.lookat{2} = last_bin_psstp;
sig_negative_cells.lookat{1} = first_bin_ngstr;
sig_negative_cells.lookat{2} = last_bin_ngstp;
