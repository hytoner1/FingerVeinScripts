%% Camera calibration
% Estimate parameters of each camera separately
% and of pairs of cameras (stereo camera sets).

%% Specify calibration images
% 'cb' stands for checkboard
cb_Images_Left = imageDatastore(fullfile('Calibration\Left'));
cb_LeftNames = cb_Images_Left.Files;
cb_Images_Right = imageDatastore(fullfile('Calibration\Right'));
cb_RightNames = cb_Images_Right.Files;
cb_Images_Middle = imageDatastore(fullfile('Calibration\Middle'));
cb_MiddleNames = cb_Images_Middle.Files;


%% Detect calibration pattern - the checkboards
% a) for single camera sets
[imagePoints_L, ~, imagesUsed_L] = detectCheckerboardPoints(cb_LeftNames);
[imagePoints_M, ~, imagesUsed_M] = detectCheckerboardPoints(cb_MiddleNames);
[imagePoints_R, ~, imagesUsed_R] = detectCheckerboardPoints(cb_RightNames);

% b) for stereo camera sets
[imagePoints_ML, boardSize, pairsUsed_ML] = detectCheckerboardPoints(cb_MiddleNames, cb_LeftNames);
[imagePoints_MR, ~, pairsUsed_MR] = detectCheckerboardPoints(cb_MiddleNames, cb_RightNames);


%% Generate world coordinates of the corners of the squares
squareSize = 10; % millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);


%% Calibration
% a) single cameras
CamParL = estimateCameraParameters(imagePoints_L, worldPoints, 'WorldUnits', 'mm');
CamParM = estimateCameraParameters(imagePoints_M, worldPoints, 'WorldUnits', 'mm');
CamParR = estimateCameraParameters(imagePoints_R, worldPoints, 'WorldUnits', 'mm');

% b) 2 stereo camera systems
stereoParams_ML = estimateCameraParameters(imagePoints_ML, worldPoints, ...
    'WorldUnits', 'mm');
stereoParams_MR = estimateCameraParameters(imagePoints_MR, worldPoints, ...
    'WorldUnits', 'mm');


%% Save the data in a .mat file
save('calibration_data.mat', 'CamParL', 'CamParM', 'CamParR', ...
    'stereoParams_ML', 'stereoParams_MR');