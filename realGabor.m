function G = realGabor(sigma, beta, f, theta, N)

    [x,y] = meshgrid(-N:N, -N:N);
% 
%     G = 1 ./ (2*pi.*sigma.*beta) .*...
%         exp(-1/2 * (x.^2 ./ sigma.^2 + y.^2 ./ beta.^2)) .*...
%         exp(2*pi.*f .* x.*cos(theta));

    G = exp( -((x.*cos(theta) + y.*sin(theta)).^2 +...
        beta^2.*(-x.*sin(theta) + y.*cos(theta)).^2) ./...
        (2*sigma^2) ) .* cos(2*pi/f*(x.*cos(theta)+y.*sin(theta)) + theta);

%     g = gabor(f, theta, 'SpatialAspectRatio', 1);
%     G = real(g.SpatialKernel);


end