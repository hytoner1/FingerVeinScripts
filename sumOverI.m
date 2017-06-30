function Iout = sumOverI(I, which)
% FUNCTION Iout = sumOverO(I, which) 
%   computes the weighted sum of images I(which) and returns it as Iout
% INPUT I     - Cell array of N images
%       which - Array of integers between [1,N] defining which images I{i}
%       are summed
    Iout = zeros(size(I{1}));
    
    for i = 1:length(which)
        Iout = Iout + I{which(i)}./length(which);
    end

end