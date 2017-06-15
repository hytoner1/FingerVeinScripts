%% Here is the main script for the project.
  % Once a part of project is completed, it can be admitted here 
 
clear variables; close all;
addpath(genpath('.'));


%% file handling - function usage
datapath = [pwd '\images']; % specify directory containing the folders with images
immap = metadata_array(datapath); % create metadata_array object
image0 = get_image(immap, 'participant', '0001', 'finger', 'right_ring',...
    'measurement', 2); % create image_container object - image+metadata
% the above is equivalent to:
% image0 = get_image(immap, 'participant', '0001', 'finger', 6, 'measurement', 2);


show_image(image0);
% finger = name_finger(image0)
% filename = image0.meta.im_fname

%% enhancement
im = image0.image;
im_enhanced = im_enhance(im);
figure(); imshow(im_enhanced, []); title('Kumar-Zhou enhancement');

%% Fast preprocessing
% I = im_enhanced;
% I = imresize(image0,0.5);               % Downscale image
% I = double(I);
% [fvr, fve] = lee_region(I,4,40);    % Get finger region

% figure(2); clf
%     CreateAxes(2,1,1)
%     imshow(fvr,[]);
%     
% jointMask = jointFinder(I, fvr);
% img_jMasked= I .* jointMask;
% 
% figure(2);
%     CreateAxes(2,1,2);
%     imshow( img_jMasked, [] );

% I_region = I .* fvr;
%% Gabor stuff
I = im_enhanced;
% I(isnan(I)) = 0;

k = 1:8;
% theta = k.*pi/8;
theta = linspace(0, pi, 8);
G = cell(size(k));

    figure(6); clf

for i = 1:length(k);
	G{i}  = realGabor(theta(i));
    I_filt{i} = imfilter(I, G{i});
%     I_filt{i} = I_filt{i} .* imerode(fvr, strel('disk',15));
%     [I_filt{i}, I_phase{i}] = imgaborfilt(I, G{i});
    
    CreateAxes(4,2,i);
        imshow((I_filt{i}), []);
        title(i);
end



I_sum = sumOverI(I_filt, 1:3);


figure(7); clf;
    imshow(I_sum,[])

    
    
    