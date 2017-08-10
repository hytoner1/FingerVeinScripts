function [eer,opt_thresh] = bt_find_eer_linint(fmr,fnmr,edges)
% More advanced method by linear interpolation, using y=ax + b

[~,I] = min(abs(fmr-fnmr));

% If fmr and fnmr are equal->easy peasy
if (fmr(I) == fnmr(I))
    eer = fmr(I)*100;
    opt_thresh = I;
    return
end

% Check if we are right of the 'zero-crossing'
if (sign(fmr(I) - fnmr(I)) == -1)
    I = I - 1;
end

dy_fmr  = fmr(I+1) - fmr(I);     % Delta y for fmr
dy_fnmr = fnmr(I+1) - fnmr(I);   % Delta y for fnmr
dx      = edges(I+1) - edges(I); % Delta x

a_fmr = dy_fmr/dx;   % Estimated slope for fmr curve
a_fnmr = dy_fnmr/dx; % Estimated slope for fnmr curve
b_fmr = fmr(I) - a_fmr*edges(I);    % Estimated offset for fmr curve
b_fnmr = fnmr(I) - a_fnmr*edges(I); % Estimated offset for fnmr curve

opt_thresh = (b_fnmr - b_fmr)/(a_fmr - a_fnmr); % Determine intersection point
eer = a_fmr*opt_thresh + b_fmr;
eer = eer*100; % As percentage