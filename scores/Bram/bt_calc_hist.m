function [n_gen,n_fls,edges] = bt_calc_hist(scores_gen,scores_fls,varargin)
% Calculates the histogram.

% Parameters:
%  scores_gen - Genuine scores
%  scores_fls - Imposter scores
%  Optional:
%    nbins - Number of bins to use
%    score_lo,score_up - Upper and lower bounds of the scores.

% Returns:
%  n_gen - Number of genuine scores for a bin
%  n_fls - Number of false scores for a bin
%  edges - edges of the bins

% Author:  Bram Ton <b.t.ton@alumnus.utwente.nl>
% Date:    5th April 2012

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

edges = linspace(score_lo,score_up,nbins+1);
n_gen = zeros(nbins,1); % Number of genuine scores
n_fls = zeros(nbins,1); % Number of imposter scores
for i=1:nbins
    n_gen(i) = sum(scores_gen >= edges(i) & scores_gen < edges(i+1));
    n_fls(i) = sum(scores_fls >= edges(i) & scores_fls < edges(i+1));
end