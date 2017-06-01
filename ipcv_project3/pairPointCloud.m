function [ptCloud, unreliable] = pairPointCloud(im1, im2, stereoParams, titles, disparity_range)
%% Images stereo rectification
[J1, J2] = rectifyStereoImages(im1, im2, stereoParams, 'OutputView','full');

% show the rectified pair of images on one plot
figure();
subplot(221);
imshow(cat(3,J1(:,:,1),J2(:,:,2:3)),'InitialMagnification',50);
title('Stereo rectification');

%% Disparity map computation
dr = disparity_range; bs = 61; ct=0.02; tt=0.00001; ut=0; dt = 450; % define parameters
disparityMap = disparity(rgb2gray(J1), rgb2gray(J2),...
    'Method', 'BlockMatching', ...
    'BlockSize',bs, 'DisparityRange',dr, 'ContrastThreshold',ct,...
    'TextureThreshold',tt, 'UniquenessThreshold',ut, 'DistanceThreshold', dt);

% post-processing of the disparity map to supress noise
disparityMap = medfilt2(disparityMap, [15 15]);

% plot disparity map
subplot(222); imshow(disparityMap, dr); title('Disparity map');
disp_3Dsceneplot = gcf;

%% 3D scene reconstruction from disparity maps and point cloud computation
[J1, ptCloud, unreliable] = createPointCloud(J1, disparityMap, stereoParams);

% display the result
figure(disp_3Dsceneplot);
subplot(224); imshow(J1,'InitialMagnification',50); title('Reconstructed 3D scene');
suptitle(titles);

end




function [J, ptCloud, unreliable] = createPointCloud(J, disparityMap, stereoParams)
%% 3D scene reconstruction
xyzPoints = reconstructScene(disparityMap, stereoParams); % reconstruct the 3D scene

% segment out the image
mmclose = -20000000; mmfar = 20000000;
Z = xyzPoints(:,:,3);
mask = repmat(Z>mmclose & Z<mmfar,[1,1,3]);
J(~mask) = 0;

%% Unreliable points determination
% there are two sources of unreliability:
%   a) points belonging to background - black in the J image,
%   b) points for which disparity is smaller than 300 (threshold adjusted
%   empirically).
% Unreliability map is an array of size of the J image, indicating the
% unreliable points by value of 1.
j = J(:,:,1) + J(:,:,2) + J(:,:,3);
[x, y] = ind2sub(size(disparityMap), find(abs(disparityMap)<300 | j==0));
unreliable = zeros(size(disparityMap)); % pre-allocate unreliability map
dm_correction = unreliable; % pre-allocate array for disparity map correction
for i=1:numel(x)
    unreliable(x(i),y(i)) = 1;
    dm_correction(x(i),y(i)) = NaN;
end

dm = disparityMap-dm_correction; %set unreliable disparity points to NaN

subplot(223);
surf(dm,'edgecolor','none'); % plot the corrected disparity map
title('Disparity map - surface plot');


%% Point cloud
xyzPoints = reconstructScene(dm, stereoParams); % repeat reconstruction with the corrected disparity map
ptCloud = pointCloud(xyzPoints, 'Color', J); % compute point cloud
end