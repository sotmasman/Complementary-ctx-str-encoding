% This script outputs the 1 way ANOVA results. Takes multiple groups and
% one measure for each of them. 
function [all_stats,all_comparisons] = do_1way_anova(thisReg,this_comp)


[~,all_stats,all_tab] = anova1(this_comp,thisReg,'off');
[c,~,~,gnames] = multcompare(all_tab);
all_comparisons = array2table(c,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
all_comparisons.("Group A") = gnames(all_comparisons.("Group A"));
all_comparisons.("Group B") = gnames(all_comparisons.("Group B"));

end