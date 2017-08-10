%% Here is the main script for the project.
  % Once a part of project is completed, it can be admitted here 
  
% I thought it could be easier to use 'main' only as a 'frame' script
% and move all the processing steps to a separate file
% (called 'single_image_processing' for now) (DD)
 
clear variables; 
close all;
addpath(genpath('.'));

saveFlag = 0; % Saveflag for images
figPos   = [495 259 858 471]; % Position for the figures on screen


%% get data
datapath = [pwd '/images']; % specify directory containing the folders with images
immap = metadata_array(datapath); % create metadata_array object
fing = 'left_ring';

% image 1
id1 = '0001';
fing1=fing;
meas1 = 2;
image1 = get_image(immap, 'participant', id1, 'finger', fing1,...
    'measurement', meas1);
% image 2
id2 = id1;
fing2 = fing;
meas2 = 1; 
image2 = get_image(immap, 'participant', id2, 'finger', fing2,...
    'measurement', meas2);

%% processing
use_joint_mask = true; %for regions extraction

image0 = image1;
single_image_processing;
u = branchp;
u_rect = branchp_rectified;
L1 = Lfinal; stats1 = stats_valid; skelD1 = skelD;
I1 = skelD;
skelD_rect1 = skelD_rectified;
cent_rect1 = cent_rectified;

image0 = image2;
single_image_processing;
v = branchp;
v_rect = branchp_rectified;
L2 = Lfinal; stats2 = stats_valid; skelD2 = skelD;
I2 = skelD;
skelD_rect2 = skelD_rectified;
cent_rect2 = cent_rectified;

%% Plotting point clouds to be matched
%
figure();
subplot(211);
scatter(u(:,2),-u(:,1),'b')
hold on
scatter(v(:,2),-v(:,1),'r')
title('no rectification');

subplot(212);
scatter(u_rect(:,2),-u_rect(:,1),'b')
hold on
scatter(v_rect(:,2),-v_rect(:,1),'r')
title('after rectification');
%}


%%
skelD_comp = cat(3, cat(3, skelD1, zeros(size(skelD1)), skelD2));
skelD_rect_comp = cat(3, cat(3, skelD_rect1, zeros(size(skelD1)), skelD_rect2));
figure(); subplot(211);  imshow(skelD_comp); title('not rectified')
subplot(212); imshow(skelD_rect_comp); title('rectified');
hold on; plot(cent_rect1(:,1), cent_rect1(:,2), 'r*');
plot(cent_rect2(:,1), cent_rect2(:,2), 'b*');
suptitle('skelD overlayed');

%% Regions matching
regions_matching;
