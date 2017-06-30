function G = realGabor(theta)

sigma = 2;
beta = sigma;
% f = sqrt(2*log(2)) ./ (2*pi*sigma);
f = 10;
N = 32;

    [x,y] = meshgrid(-N:N, -N:N);

    G = exp( -((x.*cos(theta) + y.*sin(theta)).^2 +...
        beta^2.*(-x.*sin(theta) + y.*cos(theta)).^2) ./...
        (2*sigma^2) ) .* cos(2*pi/f*(x.*cos(theta)+y.*sin(theta)) + theta);

end