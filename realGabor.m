function G = realGabor(theta)
 %% function G = realGabor(theta) returns real valued part Gabor filter G for angle theta
 
    % Parameters defining the shape and size of the filter
sigma = 2;
beta = sigma;
f = 20;
    % Size ofthe filter/2
N = 16;

    [x,y] = meshgrid(-N:N, -N:N);

    G = exp( -((x.*cos(theta) + y.*sin(theta)).^2 +...
        beta^2.*(-x.*sin(theta) + y.*cos(theta)).^2) ./...
        (2*sigma^2) ) .* cos(2*pi/f*(x.*cos(theta)+y.*sin(theta)) + theta);

end