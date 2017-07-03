function jointmask = jointFinder(img, fingerMask, debugFlag)
%% function jointMask = jointFinder(img, fingerMask)
%   Searches for the location of joints in finger image img
% INPUT:
%   img - Standard grayscale img of finger
%   fingerMask (optional): binary mask of the fonger to filter bg out
% Output:
%   jointMask: binary mask showing the location of two joints [left, right]

if nargin == 1
    fingerMask = ones(size( img ));
end
img_data = whos('img');
if strcmp(img_data.class, 'uint8')
    img = im2double(img);
end

if nargin < 3
    debugFlag = 0;
end

%% Mask the finger image
    % Weigh the mask by a cosine function to get rid of some noise on the edges
    uedge = find( imfilter(fingerMask, [-1;1]) == 1 ); % Upper edge of finger
    ledge = find( imfilter(fingerMask, [1;-1]) == 1 ); % Lower -"-
    wedge = ledge - uedge;                             % Width of -"-
        
weights = zeros(size(img));

for i = 1:length(uedge)
    weights(uedge(i):ledge(i)-1) =...
        exp( -2.* abs(linspace(0, wedge(i), wedge(i))./wedge(i) - 0.5) );
end

img_m = img .* weights;

%figure; imshow(weights,[]);

%% Find the joint location on the basis of column-wise intensity level

I = sum( img_m ) ./ sum(img_m ~= 0) ;

    % Mean filter to get rid of some saddle points
n = 10; % Width of the mean filter
Ifilt = filtfilt(ones(n,1)./n, 1, I);

    % Differentiate to get the derivative zeros
IfiltD = diff(Ifilt(1:end));
IfiltD2= zeros(size(IfiltD)) .* nan;

    % Find zero crossings as a*b <= 0 -> Crossing between a and b
for i = 2:length(IfiltD)
    IfiltD2(i) = IfiltD(i) * IfiltD(i-1);
end
[~, zeroInd] = find(IfiltD2 <= 0);

    % Ignore crossings too close to the edges of image (10% threshold)
edgeT = size(img,2) / 10;
zeroInd = zeroInd( zeroInd > edgeT & zeroInd < size(Ifilt,2)-edgeT);

IfiltZeros = Ifilt(zeroInd);    % Intensity values at zero crossings
    % Order the intensity values to descend
[~, ordered] = sort(IfiltZeros , 'descend' );

    % Plot intensity and zero crossings
if debugFlag
    figure; plot(Ifilt); hold on; plot(zeroInd, Ifilt(zeroInd),'x')
end

%% Find most probable joint locations

    % The highest is value pretty certainly one of the joints
jLoc(1) = zeroInd(ordered(1));
    
    % Disregard everything too close to this point (30% threshold)
ordered( abs(zeroInd(ordered) - jLoc(1)) < size(Ifilt,2)/3 ) = [];

    % Now the second joint should be at about the new highest value
jLoc(2) = zeroInd(ordered(1));
%% Find joint widths

    % Median value between joint locations
med = median( Ifilt(jLoc(1):jLoc(2)) );
    % Everything below median can't be joint
IfiltT = Ifilt .* (Ifilt >= med);

if debugFlag
    figure; plot(IfiltT);
end

    % Search for the edges of the joints as area that is above the
    % threshold, but not above the value at joint location
e1 = [nan, nan];
e2 = [nan, nan];

for i = 1:size(img,2)/3
    if isnan(e1(1)) && (jLoc(1)-i == 1 || IfiltT(jLoc(1)-i) == 0 || IfiltT(jLoc(1)-i) > IfiltT(jLoc(1)))
        e1(1) = jLoc(1)-i;
    end
    if isnan(e1(2)) && (IfiltT(jLoc(1)+i) == 0 || IfiltT(jLoc(1)+i) > IfiltT(jLoc(1)))
        e1(2) = jLoc(1)+i;
    end
    
    if isnan(e2(1)) && (IfiltT(jLoc(2)-i) == 0 || IfiltT(jLoc(2)-i) > IfiltT(jLoc(2)))
        e2(1) = jLoc(2)-i;
    end
    if isnan(e2(2)) && (IfiltT(jLoc(2)+i) == size(img,2) || IfiltT(jLoc(2)+i) > IfiltT(jLoc(2)))
        e2(2) = jLoc(2)+i;
    end
end
    

%% Create jointmask from the edges

jointmask = fingerMask;
jointmask(:, [1:e1(1), e1(2):e2(1), e2(2):end] ) = 0;

if debugFlag
    figure; imshow(jointmask,[])
end

end