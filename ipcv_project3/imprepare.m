function im = imprepare(im, CamPar)
    im = undistortImage(im, CamPar);
    im = remove_background(im);
end


function RGBimage = remove_background(RGBimage)
I = rgb2gray(RGBimage); % convert to grayscale

% apply Sobel edge detector
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);


se = strel('disk', 50); % create erosion and dilation structuring element

Ie = imerode(I, se); % erode the image
Iobr = imreconstruct(Ie, I); % reconstruct the eroded image

Iobrd = imdilate(Iobr, se); % dilate the reconstructed image
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr)); % reconstruct the image
Iobrcbr = imcomplement(Iobrcbr); 

fgm = imregionalmax(Iobrcbr);

se2 = strel(ones(5,5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);

fgm4 = bwareaopen(fgm3, 40);

bw = imbinarize(Iobrcbr);

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;

gradmag2 = imimposemin(gradmag, bgm | fgm4);
    
L = watershed(gradmag2);

mask = repmat(L==L(1,1) | L==L(1,end),[1,1,3]); % choose areas touching the upper corners
RGBimage(mask) = NaN; % apply mask by removing these areas from the original image
end