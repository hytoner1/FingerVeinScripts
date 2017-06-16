function jointMask = jointFinder(img, fingerMask)
%% function jointMask = jointFinder(img, fingerMask)
%   Searches for the location of joints in finger image img
% INPUT:
%   img - Standard grayscale img of finger
%   fingerMask (optional): binary mask of the fonger to filter bg out
% Output:
%   jointMask: binary mask showing the location of two joints [left, right]

if nargin == 1;
    fingerMask = ones(size( img ));
end

%% Mask the finger image

img_m = img .* fingerMask;

%% Find the joint location on the basis of column-wise intensity level

I = sum( img_m ) ./ sum(img_m ~= 0) ;

    % Mean filter to get rid of some saddle points
n = 10;
% Ifilt = conv(I, ones(n,1)./n);
Ifilt = filtfilt(ones(n,1)./n, 1, I);

    % Differentiate to get the derivative zeros
IfiltD = diff(Ifilt(1:end));
IfiltD2= zeros(size(IfiltD)) .* nan;

    % Find zero crossings as a product
for i = 2:length(IfiltD);
    IfiltD2(i) = IfiltD(i) * IfiltD(i-1);
end

    % Find the two maxima not too close to the edges
[~, zeroInd] = find(IfiltD2 < 0);

edgeT = size(img,2) / 10;
zeroInd = zeroInd( zeroInd > edgeT & zeroInd < size(Ifilt,2)-edgeT);

IfiltZeros = Ifilt(zeroInd);

[~, ordered] = sort(IfiltZeros , 'descend' );
% jLoc = sort( [zeroInd(ordered(1)), zeroInd(ordered(2))] );

figure; plot(Ifilt); hold on; plot(zeroInd, Ifilt(zeroInd),'x')


%% Find global maxima

    % The highest value pretty certainly is one of the joints
jLoc(1) = zeroInd(ordered(1));
    
    % Disregard everything too close to this value
ordered( abs(zeroInd(ordered) - jLoc(1)) < size(Ifilt,2)/3 ) = [];

    % Now the second joint should be at about the new highest value
jLoc(2) = zeroInd(ordered(1));
%% Find local minimima 

med = median( Ifilt(jLoc(1):jLoc(2)) );

IfiltT = Ifilt .* (Ifilt >= med);

figure; plot(IfiltT);

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
% 
% for i = 1:50;
%     if IfiltT(jLoc(1) - i) == 0 && isnan(e1(1));
%         e1(1) = jLoc(1) - (i-1);
%     end
%     if IfiltT(jLoc(1) + i) == 0 && isnan(e1(2));
%         e1(2) = jLoc(1) + (i-1);
%     end
%     if IfiltT(jLoc(2) - i) == 0 && isnan(e2(1));
%         e2(1) = jLoc(2) - (i-1);
%     end
%     if IfiltT(jLoc(2) + i) == 0 && isnan(e2(2));
%         e2(2) = jLoc(2) + (i-1);
%     end
%     if sum([isnan(e1), isnan(e2)]) == 0
%         break;
%     end
% end
    

%%

jointMask = fingerMask;
jointMask(:, [1:e1(1), e1(2):e2(1), e2(2):end] ) = 0;

figure; imshow(jointMask,[])


end