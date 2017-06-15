function Iout = sumOverI(I, which)

    Iout = zeros(size(I{1}));
    
    for i = 1:length(which)
        Iout = Iout + I{which(i)}./length(which);
    end

end