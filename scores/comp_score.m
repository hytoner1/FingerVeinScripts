addpath(genpath('.'));

load('mt2res.mat');

gen_score = [];
imp_score = [];

for i=1: size(matsim2,1) %tot_img
    diri = floor((i-1)/4); % genuine (same subject and finger) 4 images each finger     
    for j=1:i % Half
        dirj = floor((j-1)/4); % genuine (same subject and finger) 
        if( (diri==dirj) )
            if i~=j
                gen_score(end+1) = matsim2(i,j);
            end
        else
            imp_score(end+1) = matsim2(i,j);
        end
    end
end

[n_gen,n_fls,edges1] = bt_calc_hist(gen_score,imp_score,100,0,0.5);
figure('Name', 'Histogram')
plot(edges1(1:end-1),n_gen/sum(n_gen),'b', edges1(1:end-1),n_fls/sum(n_fls),'r')
title('Genuine vs Impostor')
xlabel('Matching Score')
ylabel('Number of Genuine/ Impostor')

[fmr,fnmr,edges] = bt_calc_rates_bins(gen_score,imp_score,500,0,0.5);
[eer,~] = bt_find_eer_linint(fmr,fnmr,edges);
fprintf('EER: %3.2f%%\n',eer);

figure();
plot(fmr,fnmr)
title('DET Curve')
xlabel('FMR')
ylabel('FNMR')