% close all;
vars = {'Centroid'};
% vars = {'Centroid', 'Area'}; %choose variables according to which the regions (represented by points) are matched
fmatch1 = table2array(stats1(:,vars));
fmatch2 = table2array(stats2(:,vars));
[k1, d1] = dsearchn(fmatch2, fmatch1);
[k2, d2] = dsearchn(fmatch1, fmatch2);
figure();
cent1 = table2array(stats1(:,'Centroid'));
cent1 = mat2gray(cent1-mean(cent1)); %whitening
plot(cent1(:,1), cent1(:,2), 'b*');
cent2 = table2array(stats2(:,'Centroid'));
cent2 = mat2gray(cent2-mean(cent2));
hold on; plot(cent2(:,1), cent2(:,2), 'r*');


d_th = 0.3*mean([median(d1), median(d2)]);
perf1 = [];
for i=1:numel(k1)
    if d1(i)<d_th
        plot([cent1(i,1),cent2(k1(i),1)], [cent1(i,2),cent2(k1(i),2)], 'b-')
        perf1 = [perf1, i];
    else
        plot([cent1(i,1),cent2(k1(i),1)], [cent1(i,2),cent2(k1(i),2)], 'b-.')
    end
end

perf2 = [];
for i=1:numel(k2)
    if d2(i)<d_th
        plot([cent2(i,1),cent1(k2(i),1)], [cent2(i,2),cent1(k2(i),2)], 'r-')
        perf2 = [perf2, i];
    else
        plot([cent2(i,1),cent1(k2(i),1)], [cent2(i,2),cent1(k2(i),2)], 'r-.')
    end
end

title('Centroids of 1 (in blue) and 2 (in red)');

figure(); hold on;
for i = 1:max(unique(L1))
    single_region = L1==i;
    single_region_boundary_cell = bwboundaries(single_region);
    single_region_boundary = single_region_boundary_cell{1,1};
    numpoints = size(single_region_boundary,1);
    ith_area = table2array(stats1(i,'Area'));
    ith_area_vector = ones(numpoints,1)*ith_area;
    scatter3(single_region_boundary(:,2), single_region_boundary(:,1),ith_area_vector,0.1,'b');
end

for i = 1:max(unique(L2))
    single_region = L2==i;
    single_region_boundary_cell = bwboundaries(single_region);
    single_region_boundary = single_region_boundary_cell{1,1};
    numpoints = size(single_region_boundary,1);
    ith_area = table2array(stats2(i,'Area'));
    ith_area_vector = ones(numpoints,1)*ith_area;
    scatter3(single_region_boundary(:,2), single_region_boundary(:,1),ith_area_vector,0.1,'r');
end