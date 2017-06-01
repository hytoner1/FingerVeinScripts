function [ptCloudScene, ptCloudRef, ptCloudAligned] = mergeptclouds(ptCloudCurrent, ptCloudRef)
% perform merging of two point clouds

% pre-processing: denoising, downsampling
ptCloudRef = pcdenoise(ptCloudRef);
ptCloudCurrent = pcdenoise(ptCloudCurrent);
gridSize = 1;
fixed = pcdownsample(ptCloudRef, 'gridAverage', gridSize);
moving = pcdownsample(ptCloudCurrent, 'gridAverage', gridSize);

% register moving point cloud on the fixed one
[tform,~] = pcregrigid(moving, fixed, ...
    'Metric', 'pointToPoint', 'Extrapolate', true, 'MaxIterations', 150, ...
    'Verbose', true, 'Tolerance', [0.005, 0.0045], ...
    'InlierRatio', 0.5);
ptCloudAligned = pctransform(ptCloudCurrent, tform); % transform the moving point cloud

ptCloudScene = pcmerge(ptCloudRef, ptCloudAligned, 0.5); % merge the two clouds
end