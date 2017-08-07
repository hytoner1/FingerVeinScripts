function tform = get_rect_tform(im_edge, jLoc)
    % Generate tform for rectification of images/data points.
    % The rectification maps cross-sections of the two joint positions with
    % estimated midline of the finger to points lying on 1/3 and 2/3 of the
    % image midline.
    % Use with imwarp to transform images or maketform + transformfwd to
    % transform data points (such as branchp).
    
    show_plot = true;

    %%
    if show_plot; figure(); imshow(im_edge); hold on; end
    height = size(im_edge,1);
    imlength = size(im_edge,2);
    edge_upper = im_edge(1:height/2,:);
    edge_lower = im_edge(height/2:end,:);

    %% linear regression
    % a) upper edge
    [edge_upper_y, edge_upper_x] = find(edge_upper);
    p_upper = polyfit(edge_upper_x, edge_upper_y, 1);
    upper_y_estimated = p_upper(1) * edge_upper_x + p_upper(2);


    % b) lower edge
    [edge_lower_y, edge_lower_x] = find(edge_lower);
    p_lower = polyfit(edge_lower_x, edge_lower_y, 1);
    lower_y_estimated = p_lower(1) * edge_lower_x + p_lower(2);


    % plot on the original image
    lower_y_estimated = lower_y_estimated + height/2;
    if show_plot
        plot(upper_y_estimated, 'y--');
        plot(lower_y_estimated, 'y--');
    end

    %% clear repetitions
    % a) upper edge
    if numel(edge_upper_x)>imlength
        [~, ia, ~] = unique(edge_upper_x);
        edge_upper_y_cleared = edge_upper_y(ia);
    else
        edge_upper_y_cleared = edge_upper_y;
    end

    % b) lower edge
    if numel(edge_lower_x)>imlength
        [~, ia, ~] = unique(edge_lower_x);
        edge_lower_y_cleared = edge_lower_y(ia);
    else
        edge_lower_y_cleared = edge_lower_y;
    end
    %% find central line
    midline_y = (edge_upper_y_cleared + edge_lower_y_cleared + height/2)/2;
    if show_plot; plot(midline_y, 'c'); end


    midline_x = [1:length(midline_y)]';
    p_midline = polyfit(midline_x, midline_y, 1);
    midline_y_estimated = p_midline(1) * midline_x + p_midline(2);
    
    if show_plot
        plot(midline_y_estimated, 'y--');
        plot([midline_x([1, end])], [height/2, height/2], 'g');
    end

    %% define matching points
    % basing on the joint positions detected by jointFinder
    midlinepts_x = round([jLoc(1), mean(jLoc), jLoc(2)]');
    midlinepts_y = round(midline_y_estimated(midlinepts_x));
    midlinepts = [midlinepts_x, midlinepts_y];
    framepts_x = round(imlength/6 * [1, 3, 5]');
    framepts_y = ones(3,1) * round(height/2);
    framepts = [framepts_x, framepts_y];
    
    if show_plot
        plot(midlinepts_x, midlinepts_y, 'm*');
        plot(framepts_x, framepts_y, 'go');
    end

    %% tform
    tform = fitgeotrans(midlinepts, framepts, 'similarity');