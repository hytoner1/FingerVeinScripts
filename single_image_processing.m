%% all steps of processing of a single image, moved here from main
% (had no better idea of how to call this script)
show_image(image0);
% finger = name_finger(image0)
% filename = image0.meta.im_fname
% set(gca, 'FontSize' ,16);
set(gcf, 'Position' ,[495 259 858 471]);
    
SaveCurrentFig(saveFlag, 1, '~/Desktop/PicsForPres/', 'orig', '-dpng');

%% Enhancement
im = image0.image;  % Read the image
[im_enhanced, fingermask] = im_enhance(im2double(im), 5, 15);  % Enhance it
fingermask_zeros = ~isnan(fingermask);	% Create a version where NaN -> 0

    % Show enhanced image
figure(); 
    imshow(im_enhanced, []); 
    title('Kumar-Zhou enhancement');
    set(gca, 'FontSize' ,16);
    set(gcf, 'Position' ,[495 259 858 471]);

SaveCurrentFig(saveFlag, 1, '~/Desktop/PicsForPres/', 'kumar-zhou', '-dpng');

%% Create masks for joint regions    
jointMask = jointFinder(im, fingermask_zeros, false);   % Find the mask for joint regions
img_jMasked= im2double(im) .* jointMask;            % Apply it for the orig image
 
    % Show the masked orig image
figure(2); clf;
    imshow(im .* fingermask_zeros./2, [0 1] );
    title('Fingermask')
    set(gca, 'FontSize' ,16);
    set(gcf, 'Position' ,[495 259 858 471]);

SaveCurrentFig(saveFlag, 1, '~/Desktop/PicsForPres/', 'fingermask', '-dpng');

figure(2); clf;
    imshow(im .* (fingermask_zeros./2 + jointMask./2), [] );
    title('Finger + joint masks')
    set(gca, 'FontSize' ,16);
    set(gcf, 'Position' ,[495 259 858 471]);
    
SaveCurrentFig(saveFlag, 1, '~/Desktop/PicsForPres/', 'jointmask', '-dpng');

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

TBSummed = 1:4; % Filtered images To Be Summed below 
I_sum = sumOverI(I_filt, TBSummed); % (Weighted) sum of said images

    % Show the sum
figure(7); clf;
    imshow(I_sum,[])
    %title(['Sum of Gabors ', mat2str(TBSummed)])
    title('Gabor filtered');
    set(gca, 'FontSize' ,16);
    set(gcf, 'Position' ,[495 259 858 471]);
    
SaveCurrentFig(saveFlag, 1, '~/Desktop/PicsForPres/', 'gabor', '-dpng');

    
    %% Miura stuff

miura_like_stuff;

%% Skeletonization and branching points extraction

im=v_rep_prcss2;
skel_and_branch