% close all;
% vars = {}; % use only rectified centroids
vars = {'Area', 'Eccentricity', 'Orientation'}; % use centroids + other variables
fmatch2 = cat(2, cent_rect1, normc(table2array(stats1(:,vars))));
fmatch1 = cat(2, cent_rect2, normc(table2array(stats2(:,vars))));
[indexPairs, matchmetric] = matchFeatures(fmatch1, fmatch2, 'Unique', true, 'MaxRatio', 0.8);
matchmetric_threshold = 1.5*median(matchmetric);

skelD_rect_zeromask = sum(skelD_rect_comp,3)==0;
skelD_rect_background = skelD_rect_comp + skelD_rect_zeromask;
figure(); imshow(skelD_rect_background); hold on;
plot(cent_rect1(:,1), cent_rect1(:,2), 'r*');
plot(cent_rect2(:,1), cent_rect2(:,2), 'b*');

matchedPoints1 = fmatch1(indexPairs(:,1),1:2);
matchedPoints2 = fmatch2(indexPairs(:,2),1:2);

matchedPoints_xx = [matchedPoints1(:,1), matchedPoints2(:,1)];
matchedPoints_yy = [matchedPoints1(:,2), matchedPoints2(:,2)];
    
for i=1:length(indexPairs)
    xx = matchedPoints_xx(i,:);
    yy = matchedPoints_yy(i,:);
    if matchmetric(i) < matchmetric_threshold
        plot(xx, yy, 'k-');
    else
        plot(xx, yy, 'k-');
    end
end

figure(); stem(matchmetric); refline(0, matchmetric_threshold);
title('Distances between the matched point pairs');

% I1 = skelD_rect1; I2 = skelD_rect2;
% figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2);