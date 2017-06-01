%% Project - stereo images reconstruction
clear variables; close all;

% load calibration data
load('calibration_data.mat');

% specify data path and define image repositories
paths = cellstr(['subject1\subject1 '; 'subject2\subject2_'; 'subject4\subject4_']);
subject = 3; % select a subject from the 'paths' array above
Images_Left = imageDatastore(fullfile(sprintf('%sLeft', char(paths(subject)))));
Images_Middle = imageDatastore(fullfile(sprintf('%sMiddle', char(paths(subject)))));
Images_Right = imageDatastore(fullfile(sprintf('%sRight', char(paths(subject)))));


% read images and perform pre-processing
n = 5; %select image set number - int, 1<=n<=5
imL = imprepare(readimage(Images_Left,n), CamParL);
imM = imprepare(readimage(Images_Middle,n), CamParM);
imR = imprepare(readimage(Images_Right,n), CamParR);

% display the pre-processed images
figure();
subplot(131); imshow(imL); title('Left image');
subplot(132); imshow(imM); title('Middle image');
subplot(133); imshow(imR); title('Right image');
suptitle('Undistorted images, after background removal');

%% Point Cloud (= ptc)
[ptc_ML, unreliable_ML] = pairPointCloud(imM, imL, stereoParams_ML, 'ML', [-480, -16]); 
[ptc_MR, unreliable_MR] = pairPointCloud(imM, imR, stereoParams_MR, 'MR', [16, 480]); 

%% Point cloud merging
% define rigid transforms basing on camera parameters
tform_ML = get_tform(stereoParams_ML);
tform_MR = get_tform(stereoParams_MR);

% transform the two point clouds to align them
ptc_ML_t = pctransform(ptc_ML, tform_ML);
ptc_MR_t = pctransform(ptc_MR, tform_MR);

% register and merge the two clouds
[ptc_merged, ptc_ref, ptc_aligned] = mergeptclouds(ptc_ML_t, ptc_MR_t);

% display the results
figure;
subplot(221); pcshowpair(ptc_MR, ptc_ML); title('before transformation');
subplot(222); pcshowpair(ptc_MR_t, ptc_ML_t); title('transformed');
subplot(223); pcshowpair(ptc_ref, ptc_aligned); title('aligned by regrigid');
subplot(224); pcshow(ptc_merged); title('merged');
suptitle('Point clouds - transformed, merged');


%% get_tform function definition
function tform = get_tform(stereoParams)
R = stereoParams.RotationOfCamera2;
t = stereoParams.TranslationOfCamera2;
H = [[R,t'];[0 0 0 1]];
tform = affine3d(H');
end