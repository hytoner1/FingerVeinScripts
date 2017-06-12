clear variables; close all;

datapath = [pwd '\images']; % specify directory containing the folders with images
immap = metadata_array(datapath); % create metadata_array object
image0 = get_image(immap, 'participant', '0001', 'finger', 3,...
    'measurement', 1);

show_image(image0);
im = image0.image;
[height, width] = size(im);

%%
figure();
subplot(221); imshow(im,[]);
title('Original image');

% Laplacian of Gaussian filtering
h = fspecial('log', 20, 2);
im_filt = imfilter(im, h, 'replicate');

% Canny edge detctor
im_filt = edge(im_filt, 'Canny', [0.01, 0.75], 0.5);
subplot(222); imshow(im_filt);
title('LoG filtered, Canny edge detector'); %the edge is continuous if you zoom in

% Extract the finger region, set the rest to NaN
im_masked = im;
immean = mean(im(:));
h2 = ceil(height/2);
nanmask = ones(height, width);
for colidx=1:width
    col = im_filt(1:h2,colidx);
    [~, idx] = max(col(:));
    im_masked(1:idx, colidx) = immean;
    nanmask(1:idx, colidx) = NaN;
    
    col = im_filt(h2:end,colidx);
    [m, idx] = max(col(:));
    im_masked((h2+idx):end, colidx) = immean;
    nanmask((h2+idx):end, colidx) = NaN;
end
subplot(223); imshow(im_masked, []);
title('Background masked with mean value');
im_adapted = adapthisteq(im_masked) .* nanmask;
subplot(224); imshow(im_adapted, []);
title('Adaptive histogram equalisation');