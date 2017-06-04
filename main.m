%% Here is the main script for the project.
  % Once a part of project is completed, it can be admitted here 
 
clear variables; close all;

%% file handling - function usage
datapath = [pwd '\images']; % specify directory containing the folders with images
immap = metadata_array(datapath); % create metadata_array object
image0 = get_image(immap, 'participant', '0001', 'finger', 'right_ring',...
    'measurement', 2); % create image_container object - image+metadata
% the above is equivalent to:
% image0 = get_image(immap, 'participant', '0001', 'finger', 6, 'measurement', 2);

show_image(image0);
finger = name_finger(image0)
filename = image0.meta.im_fname