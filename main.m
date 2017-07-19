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
meas1 = 1;
image1 = get_image(immap, 'participant', id1, 'finger', fing1,...
    'measurement', meas1);
% image 2
id2 = id1;
fing2 = fing;
meas2 = 3; 
image2 = get_image(immap, 'participant', id2, 'finger', fing2,...
    'measurement', meas2);

%% processing
use_joint_mask = true; %for regions extraction

image0 = image1;
single_image_processing;
% u = branchp;
L1 = Lfinal; stats1 = stats_valid; skelD1 = skelD;

image0 = image2;
single_image_processing;
% v = branchp;
L2 = Lfinal; stats2 = stats_valid; skelD2 = skelD;

%% Plotting point clouds to be matched
%{
figure();
scatter(u(:,2),-u(:,1),'b')
hold on
scatter(v(:,2),-v(:,1),'r')
%}
%% Regions matching
regions_matching;
