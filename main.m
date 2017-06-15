%% Here is the main script for the project.
  % Once a part of project is completed, it can be admitted here 
 
clear variables; close all;

%% file handling - function usage
datapath = [pwd '\images']; % specify directory containing the folders with images
immap = metadata_array(datapath); % create metadata_array object
image0 = get_image(immap, 'participant', '0001', 'finger', 'right_ring',...
    'measurement', 2); % create image_container object - image+metadata
% the above is equivalent to:
% image0 = get_image(immap, 'participant', '0001', 'finger', 6, 'measurement', 2);

addpath(genpath('.'));

show_image(image0);
finger = name_finger(image0)
filename = image0.meta.im_fname

%% Gabor stuff

k = 1:8;
% theta = k.*pi/8;
theta = linspace(0, pi, 8);

sigma = 3;
beta = sigma;
% f = sqrt(2*log(2)) ./ (2*pi*sigma);
f = 10;
N = 32;

G = cell(size(k));
I_phase = G;
I_filt = G;

for i = 1:length(k);
	G{i}  = realGabor(sigma, beta, f, theta(i), N);
    I_filt{i} = imfilter(I, G{i});
%     [I_filt{i}, I_phase{i}] = imgaborfilt(I, G{i});

end


% figure(5); clf; imshow(G, [])

%% 

% I_filt = imfilter(I, G, 'conv');
    figure(6); clf

for j=1:length(k)
    CreateAxes(4,2,j)
        imshow((I_filt{j}), [])

        title(j)
end

%%

I_sum = I_filt{4}./2 + I_filt{3}./2;

figure(7); clf;
    imshow(I_sum)

    
    
    