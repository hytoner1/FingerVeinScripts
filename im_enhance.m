function [im_enhanced, nanmask, im_filt] = im_enhance(im, step, bs, nanmask)

%{
Enhance image basing on the Kumar Zhou paper:
'An accurate finger vein based verification system.
Human Identification Using Finger Images'.

Includes finger boundary detection and NaN mask computation, unless the mask is 
provided during the function call.
%}

[height, width] = size(im);

%% Laplacian of Gaussian filtering and Canny edge detection
if nargin<4
  
    h = fspecial('log', 20, 2);
    im_filt = imfilter(im, h, 'replicate');
    im_filt = edge(im_filt, 'Canny', [0.01, 0.75], 0.5);
    im_filt(:,1) = im_filt(:,2); im_filt(:,end) = im_filt(:,end-1); %to correct the masking
    
    %% NaN mask for the regions outside the finger
    h2 = ceil(height/2);
    nanmask = ones(height, width);
    for colidx=1:width
        col = im_filt(1:h2,colidx);
        [~, idx] = max(col(:));
        nanmask(1:idx, colidx) = NaN;
        
        col = im_filt(h2:end,colidx);
        [~, idx] = max(col(:));
        nanmask((h2+idx):end, colidx) = NaN;
    end
    
end
%% Block average filtering
% step = 5; % number of pixels from start of one block to start of the other
% bs = 15; % half of block size
im_nan = im .* nanmask; %original image masked with NaN outside the finger region
im_pad = padarray(im_nan,[bs bs], 'replicate'); %padded image
[h, w] = size(im_pad);
backim = zeros(h, w); %background image - allocate
for vstart = (1+bs):step:(h-bs)
    for hstart = (1+bs):step:(w-bs)
        block = im_pad((vstart-bs):(vstart+bs),(hstart-bs):(hstart+bs));
        avI = nanmean(block(:)); % compute average ignoring NaNs
        if isnan(avI)
            avI = 0; % set the outside to 0
        end
        
        % put the average intensity in respective blocks of the background image
        halfstep = ceil(step/2);
        backim((vstart-halfstep):(vstart+halfstep),(hstart-halfstep):(hstart+halfstep)) = avI;
    end
end
backim = backim(bs:(end-bs-1), bs:(end-bs-1)); %remove padding
backim_downsampled = imresize(backim, 1/step); % downsample(average blocks - to points)
back_interp = imresize(backim_downsampled, [height, width]); % bicubic interpolation to size of the original image
im_subtracted = im_nan - 0.7*back_interp; % subtract scaled background image from the NaN-masked one

immean = mean(im_subtracted(~isnan(im_subtracted))); %mean value of the finger region after background subtraction
im2 = im_subtracted;
im2(isnan(im_subtracted)) = immean; %set outside of the finger to the mean (for local histogram equalisation)
im_ad_local = adapthisteq(im2, 'NumTiles', [16, 32], 'ClipLimit', 0.04) .* nanmask; % local histogram equalisation; 16 rows, 32 cols

im_enhanced = im2double(im_ad_local); %output
end
