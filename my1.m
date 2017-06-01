clear variables; close all;
% specify data path and define image repository
paths = cellstr(['0001']);
Images = imageDatastore(fullfile(sprintf(char(paths(1)))));

im = im2double(readimage(Images, 9));

[height,width] = size(im);

%%
figure(); imshow(im,[]);

%{
imt = imgaussfilt(im,5);
imt = im.*(imt<0.8);
%}


%%

h = fspecial('log', 20, 2);
im_filt = imfilter(im, h, 'replicate');



im_filt = edge(im_filt, 'Canny', [0.01, 0.75], 0.5);
figure(); imshow(im_filt);

im2 = im;
immean = mean(im(:));
h2 = ceil(height/2);
nanmask = ones(height, width);
for colidx=1:width
    col = im_filt(1:h2,colidx);
    [m, idx] = max(col(:));
    im2(1:idx, colidx) = immean;
    nanmask(1:idx, colidx) = NaN;
    
    col = im_filt(h2:end,colidx);
    [m, idx] = max(col(:));
    im2((h2+idx):end, colidx) = immean;
    nanmask((h2+idx):end, colidx) = NaN;
end
figure(); subplot(211); imshow(im2, []);
im2_ad = adapthisteq(im2) .* nanmask;
subplot(212); imshow(im2_ad, []);


%{
imt = adapthisteq(imt);
subplot(223); imshow(imt, []);

im_edge = edge(im, 'Canny', [0.01, 0.75], 0.5);
subplot(224); imshow(im_edge, []);


%
im_fft = fftshift(fft2(im));
subplot(322); imshow(log(abs(im_fft)),[]);


sigma = 10;
L = 2*ceil(sigma*4)+1;
psf = fspecial('gaussian', L, sigma);
otf = fftshift(psf2otf(psf, size(im)));
otf = max(otf(:)) - otf;
subplot(323); imshow(otf,[]);

im_fft_filt = otf .* im_fft;
subplot(324); imshow(log(abs(im_fft_filt)),[]);
[h,w] = size(im_fft);
im_fft_filt((h-20):(h+20),(1:w)) = 0;

im_filt = im2double(abs(ifft2(fftshift(im_fft_filt))));
subplot(325); imshow(im_filt,[]);

% subplot(326); imshow(im-im_filt,[]); 
%}


