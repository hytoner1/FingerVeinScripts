clear all; clc;
base_dir = 'Z:\Documents\MATLAB\project\data\';

img_per_dir = 24;
img_per_finger=4;
no_dirs = 60;
tot_img = no_dirs*img_per_dir;

%% Put all filenames in an array
allfiles = cell(tot_img, 1);
k=1;
for i=1:no_dirs
    imgs = dir(strcat(base_dir, num2str(i,'%04d'), '/*.png'));
    for j=1:length(imgs)
        fn = strcat(base_dir, num2str(i,'%04d'), '\', imgs(j).name);
        allfiles{k} = fn;
        k=k+1;
    end
end

% imshow(imread(allfiles{1}));