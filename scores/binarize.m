function BW = binarize(img)
    imgMed = median(img(img>0));    % median image
    BW = img > imgMed;
end