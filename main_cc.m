%% Here is the main script for the project.
  % Once a part of project is completed, it can be admitted here 
 
clear variables; close all;
addpath(genpath('.'));


% %% file handling - function usage
% datapath = [pwd '\images']; % specify directory containing the folders with images
% immap = metadata_array(datapath); % create metadata_array object
% image0 = get_image(immap, 'participant', '0001', 'finger', 'right_ring',...
%     'measurement', 2); % create image_container object - image+metadata
% % the above is equivalent to:
% % image0 = get_image(immap, 'participant', '0001', 'finger', 6, 'measurement', 2);
% 
% 
% show_image(image0);
% % finger = name_finger(image0)
% % filename = image0.meta.im_fname
% 
% %% Enhancement
% im = image0.image;

im = imread('0001_6_1_120509-135511.png'); 
% im1 = imread('0001_6_2_120509-135725.png');

[im_enhanced, fingermask] = im_enhance(im2double(im));
fingermask_zeros = ~isnan(fingermask);

figure(); 
    imshow(im_enhanced, []); 
    title('Kumar-Zhou enhancement');
    set(gca, 'FontSize' ,16)

%% Create masks for joint regions    
jointMask = jointFinder(im, ~isnan(im_enhanced));
img_jMasked= im2double(im) .* jointMask;
 
figure(2);
    imshow( img_jMasked, [] );

%% Gabor stuff
I = im_enhanced;
% I(isnan(I)) = 0;

k = 1:8;
% theta = k.*pi/8;
theta = linspace(0, pi/2, length(k));
G = cell(size(k));
I_filt = G;

    figure(6); clf

for i = 1:length(k);
	G{i}  = realGabor(theta(i));
    I_filt{i} = imfilter(I, G{i});
%     I_filt{i} = I_filt{i} .* imerode(fvr, strel('disk',15));
%     [I_filt{i}, I_phase{i}] = imgaborfilt(I, G{i});
    
    CreateAxes(length(k)/2,2,i, 0.1);
        imshow((I_filt{i}), []);
        title(['Angle = ', num2str(theta(i)*180/pi), ' deg']);
end

TBSummed = 1:length(k)/2; % To Be Summed below 
I_sum = sumOverI(I_filt, TBSummed);

figure(7); clf;
    imshow(I_sum,[])
    title(['Sum of Gabors ', mat2str(TBSummed)])
    set(gca, 'FontSize' ,16)
    
    
    %% Miura stuff
max_iterations = 3000; r=10; W=17; % Parameters
% v_repeated_line = miura_repeated_line_tracking(I_sum,[],max_iterations,r,W, jointMask);
v_repeated_line = miura_repeated_line_tracking(I_sum,fingermask_zeros,...
    max_iterations,r,W, jointMask);

% md = median(v_repeated_line(v_repeated_line>0));
% v_repeated_line_bin = v_repeated_line > md; 
v_repeated_line_bin = binarize(v_repeated_line);

CC_rep = connectedComp(v_repeated_line_bin,200); % Find connected component > 200

sigma = 3;
v_max_curvature = miura_max_curvature(I_sum,fingermask_zeros,sigma);
v_max_curvature_bin = binarize(v_max_curvature);
CC_curv = connectedComp(v_max_curvature_bin,10); % Find connected component > 10

% figure(5); clf;
figure;
    CreateAxes(2,2,1);
    imshow(v_repeated_line, []);
    title('repeated line');

    CreateAxes(2,2,2);
    imshow(v_repeated_line_bin, []);
    title('repeated line binarize');
    
    CreateAxes(2,2,3);
    imshow(CC_rep, []);
    title('repeated line with connected component');
    
    CreateAxes(2,2,4);
    imshowpair(im_enhanced,CC_rep);
    
figure;
    CreateAxes(2,2,1);
    imshow(v_max_curvature, []);
    title('max curvature');

    CreateAxes(2,2,2);
    imshow(v_max_curvature_bin, []);
    title('max curvature binarize');
    
    CreateAxes(2,2,3);
    imshow(CC_curv, []);
    title('max curvature with connected component');
    
    CreateAxes(2,2,4);
    imshowpair(im_enhanced,CC_curv);