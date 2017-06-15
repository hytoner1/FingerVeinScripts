% Howto use the miura_* scripts.

cd ~/Dropbox/ACVPR/FingerVeinScripts/;
addpath(genpath('./'));

img = im2double(imread('finger.png')); % Read the image
img = imresize(img,0.5);               % Downscale image

% Get the valid region, this is a binary mask which indicates the region of 
% the finger. For quick testing it is possible to use something like:
% fvr = ones(size(img));
% The lee_region() function can be found here:

figure(1); clf;
    CreateAxes(3,1,1);
    imshow(img,[]);

[fvr, fve] = lee_region(img,4,40);    % Get finger region

    CreateAxes(3,1,2);
    imshow(fvr,[]);
    
%% Find the joints

jointMask = jointFinder(img, fvr);
img_jMasked= img .* jointMask;

figure(1);
    CreateAxes(3,1,3);
    imshow( img_jMasked, [] );

    
%% Extract veins using maximum curvature method
sigma = 3; % Parameter
v_max_curvature = miura_max_curvature(img,fvr,sigma);
j_max_curvature = miura_max_curvature(img,jointMask,sigma);
% v_max_curvature = adapthisteq(v_max_curvature);

    figure(2); clf;
    CreateAxes(2,2,1);
    imshow(v_max_curvature, []);
    CreateAxes(2,2,2);
    imshow(j_max_curvature, []);

% Binarise the vein image
md = median(v_max_curvature(v_max_curvature>0));
v_max_curvature_bin = v_max_curvature > md; 

md_j = median(j_max_curvature(j_max_curvature>0));
j_max_curvature_bin = j_max_curvature > md_j; 

% for i = 1:size(v_max_curvature_bin,2);
%     v_max_curvature_bin(fve(:,i),i) = 1;
% end

    CreateAxes(2,2,3);
    imshow(v_max_curvature_bin, []);
    CreateAxes(2,2,4);
    imshow(j_max_curvature_bin, []);
    

%% Extract veins using repeated line tracking method
max_iterations = 3000; r=10; W=17; % Parameters
v_repeated_line = miura_repeated_line_tracking(img,fvr,max_iterations,r,W, jointMask);

% Binarise the vein image
md = median(v_repeated_line(v_repeated_line>0));
v_repeated_line_bin = v_repeated_line > md; 

% figure(5); clf;
figure;
    CreateAxes(2,1,1);
    imshow(v_repeated_line, []);

    CreateAxes(2,1,2);
    imshow(v_repeated_line_bin, []);
    
    
%% Make the structure more into my liking

v_close = imopen(v_repeated_line_bin, strel('disk',1));

v_skel  = bwmorph(v_close, 'skel', inf);
% 
for j = floor(linspace(1+20,size(v_close,2)-20,9))
    v_close(:,j) = 1;
    v_skel(:,j) = 1;
end

figure(6); clf;
    CreateAxes(2,1,1);
    imshow(v_close, []);

    CreateAxes(2,1,2);
    imshow(v_skel, []);

CC = bwconncomp(v_close);
CC2 = bwconncomp(v_skel);

%% Try watershed

v_ws = watershed(v_close, 4);
v_ws2 = watershed(v_skel, 4);

figure(4); clf;
    CreateAxes(2,1,1);
    imshow(v_ws, []);

    CreateAxes(2,1,2);
    imshow(v_ws2, []);


%% Match
cw = 80; ch=30;
% Note that the match score is between 0 and 0.5
score = miura_match(double(v_repeated_line_bin), double(v_max_curvature_bin), cw, ch);
fprintf('Match score: %6.4f %%\n', score);

%% Visualise
% Overlay the extracted veins on the original image
overlay_max_curvature = zeros([size(img) 3]);
overlay_max_curvature(:,:,1) = img;
overlay_max_curvature(:,:,2) = img + 0.4*v_max_curvature_bin;
overlay_max_curvature(:,:,3) = img;

% Overlay the extracted veins on the original image
overlay_repeated_line = zeros([size(img) 3]);
overlay_repeated_line(:,:,1) = img;
overlay_repeated_line(:,:,2) = img + 0.4*v_repeated_line_bin;
overlay_repeated_line(:,:,3) = img;

figure;
subplot(3,2,1)
  imshow(img,[])
  title('Original captured image')
subplot(3,2,2)
  imshow(fvr)
  title('Detected finger region')
subplot(3,2,3)
  imshow(v_max_curvature_bin)
  title('Binarised veins extracted by maximum curvature method')
subplot(3,2,4)
  imshow(overlay_max_curvature)
  title('Maximum curvature method')  
subplot(3,2,5)
  imshow(v_repeated_line_bin)
  title('Binarised veins extracted by repeated line tracking method')
subplot(3,2,6)
  imshow(overlay_repeated_line)
  title('Repeated line tracking method')