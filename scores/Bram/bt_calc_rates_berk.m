function [fmr,fnmr,edges] = bt_calc_rates_berk(scores_gen,scores_fls)
% Calculate the FMR and FNMR based on the existing match scores.

edges = sort([scores_gen; scores_fls]);
fmr   = zeros(length(edges),1);
fnmr  = zeros(length(edges),1);
parfor i=1:length(edges)
    fmr(i) =  length(find(scores_fls >= edges(i))); % False positives
    fnmr(i) = length(find(scores_gen  < edges(i))); % False negatives
end
fmr  = fmr./length(scores_fls);
fnmr = fnmr./length(scores_gen);