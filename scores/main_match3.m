%% Here is the main script for the project.
  % Once a part of project is completed, it can be admitted here 
 
% clear variables; close all;
% addpath(genpath('.'));
% 
% load('mtrain1.mat');
% % %% file handling - function usage
% % datapath = [pwd '/images']; % specify directory containing the folders with images
% % immap = metadata_array(datapath); % create metadata_array object
% % image0 = get_image(immap, 'participant', '0001', 'finger', 'right_ring',...
% %     'measurement', 1); % create image_container object - image+metadata
% % % The above is equivalent to:
% % %   image0 = get_image(immap, 'participant', '0001', 'finger', 6, 'measurement', 2);
% % 
% % 
% % show_image(image0);
% % % finger = name_finger(image0)
% % % filename = image0.meta.im_fname
% % 
% % %% Enhancement
% % im = image0.image;  % Read the image
% % im = imread('0001_6_1_120509-135511.png');
% % im2 = imread ('0004_1_3_120523-105359.png');
% % im2 = imread ('0001_6_4_120523-101054.png');
% 
% matsim = zeros(140); % training 35 different subject
% 
% for pr1=1 : 1
%     for pr2=1 : 1
function score = main_match3(im,im2)        


[im_enhanced2, fingermask2] = im_enhance(im2double(im2),5,15);  % Enhance it
[im_enhanced, fingermask] = im_enhance(im2double(im),5,15);  % Enhance it
fingermask_zeros = ~isnan(fingermask);	% Create a version where NaN -> 0
fingermask_zeros2 = ~isnan(fingermask2);	% Create a version where NaN -> 0

% figure(); 
%     imshow(im_enhanced2, []);
%     % Show enhanced image
% figure(); 
%     imshow(im_enhanced, []); 
%     title('Kumar-Zhou enhancement');
%     set(gca, 'FontSize' ,16)

%% Create masks for joint regions    
jointMask = jointFinder(im, fingermask_zeros);   % Find the mask for joint regions
img_jMasked= im2double(im) .* jointMask;            % Apply it for the orig image
jointMask2 = jointFinder(im2, fingermask_zeros2);   % Find the mask for joint regions
img_jMasked2= im2double(im2) .* jointMask2;            % Apply it for the orig image 
    
% Show the masked orig image
% figure(); clf;
%     imshow( img_jMasked, [] );
% figure(); clf;
%     imshow( img_jMasked2, [] );

%% Gabor stuff
I = im_enhanced;    % Copy the enhanced file
I(isnan(I)) = 0;    % Convert NaNs to zeros for filtering to work
I2 = im_enhanced2;    % Copy the enhanced file
I2(isnan(I2)) = 0;    % Convert NaNs to zeros for filtering to work

k = 8;              % The number of gabor filters to be applied
theta = linspace(0, pi/2, k);   % Corresponding angles
G = cell(1, k);     % Store filters here
I_filt = G;         % Store filtered images here
I_filt2 = G;         % Store filtered images here

%     figure(); clf
for i = 1:k
	G{i}  = realGabor(theta(i));    % Create Gabor filter for angle theta
    I_filt{i} = imfilter(I, G{i});  % Apply the filter
    I_filt2{i} = imfilter(I2, G{i});  % Apply the filter
    
        % Show the filtered images
%     CreateAxes(2,k/2,i, 0.1);  
%         imshow(I_filt{i}, []);
%         title(['Angle = ', num2str(theta(i)*180/pi), ' deg']);
%     CreateAxes(3,k/2,i, 0.1);  
%         imshow(I_filt2{i}, []);
%         title(['Angle = ', num2str(theta(i)*180/pi), ' deg']);
end

TBSummed = 1:k/2; % Filtered images To Be Summed below 
I_sum = sumOverI(I_filt, TBSummed); % (Weighted) sum of said images
I_sum2 = sumOverI(I_filt2, TBSummed); % (Weighted) sum of said images

    % Show the sum
% figure(); clf;
%     imshow(I_sum,[])
%     title(['Sum of Gabors ', mat2str(TBSummed)])
%     set(gca, 'FontSize' ,16)
% 
% figure(); clf;
%     imshow(I_sum2,[])
%     title(['Sum of Gabors ', mat2str(TBSummed)])
%     set(gca, 'FontSize' ,16)    
%     
    %% Miura stuff
%% This is a script called by main.m, that does the whole miura line of processing
    % (With Roni-esque twists)

max_iterations = 5000; r=10; W=17; % Parameters 10000
% v_repeated_line = miura_repeated_line_tracking(I_sum,[],max_iterations,r,W, jointMask);
v_repeated_line = miura_repeated_line_tracking(I_sum,fingermask_zeros,...
   max_iterations,r,W, jointMask);
v_repeated_line2 = miura_repeated_line_tracking(I_sum2,fingermask_zeros2,...
   max_iterations,r,W, jointMask2);
% v_curvature = miura_max_curvature(I_sum, fingermask_zeros, 5);

% md = median(v_repeated_line(v_repeated_line>0));
% v_repeated_line_bin = v_repeated_line > md; 
% v_repeated_line_bin = binarize(v_repeated_line);
% v_repeated_line_bin2 = binarize(v_repeated_line2);

% figure(5); clf;
% figure;
%     CreateAxes(2,1,1);
%     imshow(v_repeated_line, []);
% 
%     CreateAxes(2,1,2);
%     imshow(v_repeated_line2, []);
    
    %% Work on miura images
    
    % Perform closing on the 'hazy' image
SE = strel('disk', 2);
    % This could be switched to Gabor / Gaussian filtering ?
% v_rep_prcss  = imclose(v_repeated_line, SE);
% v_rep_prcss22  = imclose(v_repeated_line2, SE);

v_rep_prcss  = imgaussfilt(v_repeated_line,2);
v_rep_prcss22  = imgaussfilt(v_repeated_line2,2);

    % Remove the NaN, enhance, binarize, close
v_rep_prcss2 = v_rep_prcss;
v_rep_prcss222 = v_rep_prcss22;

v_rep_prcss2(isnan(v_rep_prcss2)) = 0;
v_rep_prcss222(isnan(v_rep_prcss222)) = 0;

% imt = im_enhance(v_rep_prcss2, fingermask);
% imt2 = im_enhance(v_rep_prcss222, fingermask2);
% 
% v_rep_prcss2 = im2bw(imt,graythresh(imt));
% v_rep_prcss222 = im2bw(imt2,graythresh(imt2));

v_rep_prcss2 = imbinarize(im_enhance(v_rep_prcss2,5,15, fingermask));
v_rep_prcss222 = imbinarize(im_enhance(v_rep_prcss222,5,15, fingermask2));

v_rep_prcss2 = imclose(v_rep_prcss2, SE);
v_rep_prcss222 = imclose(v_rep_prcss222, SE);

    % Find the largest connected component and remove the rest
CC = bwconncomp(v_rep_prcss2);
    [~, max_idx] = max(cellfun('size', CC.PixelIdxList, 1));
CC2 = bwconncomp(v_rep_prcss222);
    [~, max_idx2] = max(cellfun('size', CC2.PixelIdxList, 1));
    
v_rep_prcss3 = zeros(size(v_rep_prcss2)); 
    v_rep_prcss3(CC.PixelIdxList{max_idx}) = 1;
v_rep_prcss32 = zeros(size(v_rep_prcss222)); 
    v_rep_prcss32(CC2.PixelIdxList{max_idx2}) = 1;
    
    % Find the smallest inverse components (i.e. holes) and fill them 
CC_inv = bwconncomp(imcomplement(v_rep_prcss3));
    [~, small_idx] = find(cellfun('size', CC_inv.PixelIdxList, 1) < 200);
CC_inv2 = bwconncomp(imcomplement(v_rep_prcss32));
    [~, small_idx2] = find(cellfun('size', CC_inv2.PixelIdxList, 1) < 200);
    
v_rep_prcss3(cell2mat(CC_inv.PixelIdxList(small_idx)')) = 1;
v_rep_prcss32(cell2mat(CC_inv2.PixelIdxList(small_idx2)')) = 1;
%     SE2 = strel('disk', 3);

% cw = 50; ch=100;
% % Note that the match score is between 0 and 0.5
% score = miura_match(v_rep_prcss3, v_rep_prcss32,cw,ch);
% % score = miura_match(double(v_repeated_line_bin), double(v_repeated_line_bin),cw,ch);
% % score = 
% fprintf('Match score: %3.2f%%\n', score*200);

    % Paint me like one of your french girls
% figure;
%     CreateAxes(2,1,1);
%     imshow(bwmorph(v_rep_prcss3, 'skel', Inf), []);
% 
%     CreateAxes(2,1,2);
%     imshow(v_rep_prcss3, []);
% 
% figure;
%     CreateAxes(2,1,1);
%     imshow(bwmorph(v_rep_prcss32, 'skel', Inf), []);
% 
%     CreateAxes(2,1,2);
%     imshow(v_rep_prcss32, []);
%  


cw = 50; ch=100;
% Note that the match score is between 0 and 0.5
score = miura_match(v_rep_prcss3, v_rep_prcss32,cw,ch);
% score = miura_match(double(v_repeated_line_bin), double(v_repeated_line_bin),cw,ch);
% score = 
% fprintf('Match score %d and %d : %3.2f%%\n ', mt{pr1,1},mt{pr2,1},score*200);

% matsim(pr1,pr2) = score;
%     end
% end
end
%%
% skel= bwmorph(v_rep_prcss3,'skel',Inf); %scheletonized image
% figure, imshow(skel);
% B = bwmorph(skel, 'branchpoints');
% E = bwmorph(skel, 'endpoints');
% [y,x] = find(E);
% B_loc = find(B);
% Dmask = zeros(size(skel));
% % Start at a endpoint, start walking and find all pixels that are closer 
% % than the nearest branchpoint. Then remove those pixels.
% for k = 1:length(x)
%     D = bwdistgeodesic(skel,x(k),y(k));
%     distanceToBranchPt = min(D(B_loc));
%     Dmask(D < distanceToBranchPt) = true;
% end
% skelD = skel - Dmask;
% figure, imshow(skelD);

