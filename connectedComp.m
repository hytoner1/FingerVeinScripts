function CC = connectedComp(imageBW,minTH)  
%Find largest connected part  
%conn = 8; % 8-neighbourhod
ConnectedComponents = bwconncomp(imageBW);
numPixels = cellfun(@numel,ConnectedComponents.PixelIdxList);
% [biggest,idx] = max(numPixels);
% imageBW(ConnectedComponents.PixelIdxList{idx}) = 0;

CC = zeros(size(imageBW));

for i=1:1:size(numPixels,2)
    if(numPixels(i)>minTH)        
        CC(ConnectedComponents.PixelIdxList{i}) = 1;
    end
end