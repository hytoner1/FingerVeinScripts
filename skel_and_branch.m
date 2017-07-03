%% Skeletonization

skel= bwmorph(v_rep_prcss3,'skel',Inf); %skeletonized image
figure, imshow(skel);
B = bwmorph(skel, 'branchpoints');
E = bwmorph(skel, 'endpoints');
[y,x] = find(E);
B_loc = find(B);
Dmask = zeros(size(skel));
% Start at a endpoint, start walking and find all pixels that are closer 
% than the nearest branchpoint. Then remove those pixels.
for k = 1:length(x)
    D = bwdistgeodesic(skel,x(k),y(k));
    distanceToBranchPt = min(D(B_loc));
    Dmask(D < distanceToBranchPt) = true;
end
skelD = skel - Dmask;
figure, imshow(skelD);
im_overlaid = im_enhanced + skelD;
figure, imshow(im_overlaid,[])
%figure, imshow(im_overlaid.*jointMask,[])

%% Branching points detection

branchp=[];
for i=2:size(skelD,1)-1
    for j=2:size(skelD,2)-1

        if skelD(i,j)==1
            transition=0;
            count=0;
            %looking for a black pixel around (i,j)
            for k=-1:+1
                for l=-1:+1
                    if (skelD(i+k,j+l)==0) %(i,j)==1 for sure
                        %start clockwise exploration of the neighborhood of the
                        %candidate branching point from that black point (s.t. I
                        %count only positive transitions)
                        prev=0;
                        while count<8 %clockwise exploration of the neighborhood
                            count=count+1;
                            if(k==-1)
                                if(l==-1 || l==0) l=l+1;
                                else k=k+1; 
                                end
                            elseif(k==+1)
                                if(l==0 || l==+1) l=l-1;
                                else k=k-1;
                                end
                            else
                                if(l==-1) k=k-1;
                                elseif(l==+1) k=k+1; 
                                end
                            end
                            
                            if (skelD(i+k,j+l)==1 && prev==0)
                                transition=transition+1;
                                prev=1;
                            end
                            if skelD(i+k,j+l)==0
                                prev=0;
                            end
                        end
                        if transition>2
                            branchp=[branchp;[i j]];
                        end 
                         %k=+2; %go to the next (i+1,j+1) pixel
                         %l=+2; %go to the next (i+1,j+1) pixel
                    end
                    if count==8 break; %go to the next (i+1,j+1) pixel
                    end
                end
                if count==8 break; %go to the next (i+1,j+1) pixel
                end
            end
        end
    end
end

figure, imshow(skelD,[])
hold on
plot(branchp(:,2), branchp(:,1), 'ro','MarkerFaceColor','r')