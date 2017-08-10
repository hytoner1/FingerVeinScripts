% clear variables; close all;
addpath(genpath('.'));

load('mt2.mat');

matsim2 = zeros(48); % training 2 different subject, 6 finger and 4 images each finger

for pr1=1 : 48
    for pr2=1 : pr1
        if pr1 == pr2
            matsim2(pr1,pr2) = 1;
        else
            im  = imread(mt2{pr1,2});
            im2  = imread(mt2{pr2,2});
            try
                score = main_match3(im,im2);
                fprintf('Match score %d and %d : %3.2f%%\n ', mt2{pr1,1},mt2{pr2,1},score*200);
                matsim2(pr1,pr2) = score;
            catch
                warning('Problem using function.  Assigning a value of 0.');
                fprintf('---- Match score %d and %d : --- ', mt2{pr1,1},mt2{pr2,1});
                continue
            end
        end
    end
end