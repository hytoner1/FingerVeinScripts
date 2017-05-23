function [fve] = roni_edge(fvr)

    % Allocate memory
% fvr = zeros(size(img));
% fve = zeros(size(img));

    % Compute dy
kern = [0.5; -0.5]; % a nice gaussian kernel could be used
fve = conv2(fvr, kern);


% for i = 1:size(img,2)
%     b = a(:,i);
%     k = local_max(b);
%     k2 = b(k);
%     [Y,I] = sort(k2);
%     
%     e1 = k(I==1);
%     e2 = k(I==2);
%     
%     fvr(min(e1,e2):max(e1,e2), i) = 1;
%     fve([e1,e2], i) = 1;
% end

end