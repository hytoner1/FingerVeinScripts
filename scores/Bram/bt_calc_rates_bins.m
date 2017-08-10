function [fmr,fnmr,edges] = bt_calc_rates_bins(scores_gen,scores_fls,varargin)

% Default values
nbins = 100;
score_lo = 0; % Lower bound of possible scores
score_up = 1; % Upper bound of possible scores

optargin = size(varargin,2); % Number of variable arguments
if(optargin==1)
    nbins = varargin{1};
end
if(optargin==3)
    nbins = varargin{1};
    score_lo = varargin{2};
    score_up = varargin{3};
end

fmr   = zeros(nbins,1);
fnmr  = zeros(nbins,1);
edges = linspace(score_lo,score_up,nbins);
for i=1:nbins
    fmr(i) =  length(find(scores_fls >= edges(i))); % False positives
    fnmr(i) = length(find(scores_gen  < edges(i))); % False negatives
end
fmr  = fmr./length(scores_fls);
fnmr = fnmr./length(scores_gen);