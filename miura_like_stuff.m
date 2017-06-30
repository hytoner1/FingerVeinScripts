%% This is a script called by main.m, that does the whole miura line of processing
    % (With Roni-esque twists)

max_iterations = 10000; r=10; W=17; % Parameters
% v_repeated_line = miura_repeated_line_tracking(I_sum,[],max_iterations,r,W, jointMask);
v_repeated_line = miura_repeated_line_tracking(I_sum,fingermask_zeros,...
   max_iterations,r,W, jointMask);
v_curvature = miura_max_curvature(I_sum, fingermask_zeros, 5);

md = median(v_repeated_line(v_repeated_line>0));
v_repeated_line_bin = v_repeated_line > md; 

% figure(5); clf;
figure;
    CreateAxes(2,1,1);
    imshow(v_repeated_line, []);

    CreateAxes(2,1,2);
    imshow(v_curvature, []);
    
    %% Work on miura images
    
    % Perform closing on the 'hazy' image
SE = strel('disk', 2);
    % This could be switched to Gabor / Gaussian filtering ?
v_rep_prcss  = imclose(v_repeated_line, SE);

    % Remove the NaN, enhance, binarize, close
v_rep_prcss2 = v_rep_prcss;
v_rep_prcss2(isnan(v_rep_prcss2)) = 0;
v_rep_prcss2 = imbinarize(im_enhance(v_rep_prcss2, fingermask));
v_rep_prcss2 = imclose(v_rep_prcss2, SE);

    % Find the largest connected component and remove the rest
CC = bwconncomp(v_rep_prcss2);
    [~, max_idx] = max(cellfun('size', CC.PixelIdxList, 1));

v_rep_prcss3 = zeros(size(v_rep_prcss2)); 
    v_rep_prcss3(CC.PixelIdxList{max_idx}) = 1;

    % Find the smallest inverse components (i.e. holes) and fill them 
CC_inv = bwconncomp(imcomplement(v_rep_prcss3));
    [~, small_idx] = find(cellfun('size', CC_inv.PixelIdxList, 1) < 200);
    
    v_rep_prcss3(cell2mat(CC_inv.PixelIdxList(small_idx)')) = 1;
    SE2 = strel('disk', 3);

    % Paint me like one of your french girls
figure;
    CreateAxes(2,1,1);
    imshow(bwmorph(v_rep_prcss3, 'skel', Inf), []);

    CreateAxes(2,1,2);
    imshow(v_rep_prcss3, []);
