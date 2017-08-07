if exist('use_joint_mask', 'var')==0
    use_joint_mask=false;
end

figure();
% close the areas - use boundaries of the jointMask
% or introduce left and right vertical edges
if use_joint_mask
    if exist('jointMask', 'var')==0
        jointMask = jointFinder(im);
    end
    skelD=skelD.*jointMask; %uncomment if you want to use the joint mask
    
    jointMask_boundary = bwperim(jointMask,4);
    skelD = max(skelD, jointMask_boundary);
else

    skelrow_nonzero = find(sum(skelD)~=0);
    boundleft_col = skelrow_nonzero(1)+10;
    boundright_col = skelrow_nonzero(end)-10;

    skelcol_left_nonzero = find(skelD(:,boundleft_col) ~= 0);
    boundleft_rows = [skelcol_left_nonzero(1):skelcol_left_nonzero(end)];
    skelD(boundleft_rows,boundleft_col)=1;

    skelcol_right_nonzero = find(skelD(:,boundright_col) ~= 0);
    boundright_rows = [skelcol_right_nonzero(1):skelcol_right_nonzero(end)];
    skelD(boundright_rows,boundright_col)=1;
end

subplot(223); imshow(skelD); title('skeletonisation');



%% regionprops, choose regions and all the rest

cc = bwconncomp(1-skelD, 4);
L = labelmatrix(cc);
labels_unique = setdiff(unique(L),0);

subplot(224); imshow(label2rgb(L)); title('regions');
figure();
subplot(221); imshow(label2rgb(L)); title('all found regions');


stats = regionprops('table', cc, 'Centroid', 'Eccentricity', 'Area', 'Orientation');
areas = [stats.Area];
th_low = 500; th_high = 50000;
idx = find(areas>th_low & areas<th_high);
labels_valid = labels_unique(idx);
labels_invalid = setdiff(labels_unique, labels_valid);


subplot(222); stem(labels_unique, areas);
hold on; refline(0,th_low); refline(0, th_high);
xlim([-1, max(labels_unique+1)]); ylim([0, 10000]);
title('areas of the regions');

subplot(223); stem(idx, areas(labels_valid), 'g');
hold on; stem(labels_invalid, zeros(1, numel(labels_invalid)), 'r');
refline(0,th_low); refline(0, th_high);
xlim([-1, max(labels_unique+1)]); ylim([0, 1.1*th_high]);
title('areas - thresholded');


stats_valid = stats(idx,:);
BW2 = ismember(labelmatrix(cc), idx);
Lfinal = labelmatrix(bwconncomp(BW2,4));
Lfinal_rgb = label2rgb(Lfinal);

subplot(224); imshow(Lfinal_rgb); title('chosen regions');

figure(); imshow(Lfinal_rgb);
cent = table2array(stats_valid(:,'Centroid'));
hold on; plot(cent(:,1), cent(:,2), 'k*');
suptitle('Centroids of the chosen regions');

%% rectify centroids array
cent_rectified = tformfwd(maketform('affine', rect_tform.T), cent);