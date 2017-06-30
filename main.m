%% Here is the main script for the project.
  % Once a part of project is completed, it can be admitted here 
 
clear variables; close all;
addpath(genpath('.'));


%% file handling - function usage
datapath = [pwd '/images']; % specify directory containing the folders with images
immap = metadata_array(datapath); % create metadata_array object
image0 = get_image(immap, 'participant', '0001', 'finger', 'right_ring',...
    'measurement', 2); % create image_container object - image+metadata
% The above is equivalent to:
%   image0 = get_image(immap, 'participant', '0001', 'finger', 6, 'measurement', 2);


show_image(image0);
% finger = name_finger(image0)
% filename = image0.meta.im_fname

%% Enhancement
im = image0.image;  % Read the image
[im_enhanced, fingermask] = im_enhance(im2double(im));  % Enhance it
fingermask_zeros = ~isnan(fingermask);	% Create a version where NaN -> 0

    % Show enhanced image
figure(); 
    imshow(im_enhanced, []); 
    title('Kumar-Zhou enhancement');
    set(gca, 'FontSize' ,16)

%% Create masks for joint regions    
jointMask = jointFinder(im, ~isnan(im_enhanced));   % Find the mask for joint regions
img_jMasked= im2double(im) .* jointMask;            % Apply it for the orig image
 
    % Show the masked orig image
figure(2);
    imshow( img_jMasked, [] );

%% Gabor stuff
I = im_enhanced;    % Copy the enhanced file
I(isnan(I)) = 0;    % Convert NaNs to zeros for filtering to work

k = 8;              % The number of gabor filters to be applied
theta = linspace(0, pi/2, k);   % Corresponding angles
G = cell(1, k);     % Store filters here
I_filt = G;         % Store filtered images here


    figure(6); clf
for i = 1:k
	G{i}  = realGabor(theta(i));    % Create Gabor filter for angle theta
    I_filt{i} = imfilter(I, G{i});  % Apply the filter
    
        % Show the filtered images
    CreateAxes(2,k/2,i, 0.1);  
        imshow(I_filt{i}, []);
        title(['Angle = ', num2str(theta(i)*180/pi), ' deg']);
end

TBSummed = 1:k/2; % Filtered images To Be Summed below 
I_sum = sumOverI(I_filt, TBSummed); % (Weighted) sum of said images

    % Show the sum
figure(7); clf;
    imshow(I_sum,[])
    title(['Sum of Gabors ', mat2str(TBSummed)])
    set(gca, 'FontSize' ,16)
    
    
    %% Miura stuff
max_iterations = 3000; r=10; W=17; % Parameters
% v_repeated_line = miura_repeated_line_tracking(I_sum,[],max_iterations,r,W, jointMask);
v_repeated_line = miura_repeated_line_tracking(I_sum,fingermask_zeros,...
   max_iterations,r,W, jointMask);
v_curvature = miura_max_curvature(I_sum, fingermask_zeros, 3);

md = median(v_repeated_line(v_repeated_line>0));
v_repeated_line_bin = v_repeated_line > md;
v_repeated_line_bin2 = v_repeated_line > 1.5*md;

% figure(5); clf;
figure;
    CreateAxes(2,1,1);
    imshow(v_repeated_line, []);

    CreateAxes(2,1,2);
    imshow(v_curvature, []);