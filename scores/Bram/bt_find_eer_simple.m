function [eer,opt_thresh] = bt_find_eer_simple(fmr,fnmr,edges)
% Simple method for calculating EER

[~,I] = min(abs(fmr-fnmr));
eer = (fmr(I) + fnmr(I))/2;
eer = eer*100; % As percentage
opt_thresh = edges(I);