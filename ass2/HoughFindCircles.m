function [] = HoughFindCircles( I_edge )
    
    % magic
    threshold = 0.8;
    eps = 3;
    
    % hough max dim
    % assuming center of circle is within pic dim, and the radius is less
    % than half the picture size
    a_max = length(I_edge(1,:));
    b_max = length(I_edge(:,1));
    r_max = round(min(a_max, b_max) / 2);
    
    % dims: y_0, x_0, r
    A = zeros(b_max, a_max, r_max);
    
    % create vote matrix
    for r=4:r_max
        vote_kernel = CreateCircleKernel(r);
        norm_factor = sum(vote_kernel(:));
        
        votes = conv2(I_edge, vote_kernel); % vote
        votes = votes(1+r : b_max+r , 1+r : a_max+r); % cut size of pic
        votes = votes ./ norm_factor; % normalize to [0,1]
        A(:,:,r) = A(:,:,r) + votes;
    end
    
    % find local maxima
    [~, sortedInds] = sort(A(:),'descend');
    for i=1:length(sortedInds)
        curr_idx = sortedInds(i);
        if A(curr_idx) < threshold
            break; % all other values will be lower than threshold
        end
        [y,x,r] = ind2sub(size(A), curr_idx);
        area = A(y-eps:y+eps , x-eps:x+eps , r-eps:r+eps);
        max_in_area = max(area(:));
        if A(curr_idx) >= max_in_area
            A(curr_idx) = 2; % ~inf, since the matrix is normalize to [0,1]
        end
    end
    
    % find the local maxima from last step (will be with the value of 2)
    B = A == 2;
    circles_idx = find(B);
    fprintf('number of circles found: %d\n', length(circles_idx));
    
    % print
    figure();
    imshow(imread('coins.png'));
    [Y,X,R] = ind2sub(size(A), circles_idx);
    viscircles([X Y], R, 'color', 'b');
    title(['hough circle detection, found ', num2str(length(circles_idx)), ' circles']);
end

function [circle_kernel] = CreateCircleKernel(r)
    circle_kernel = zeros(r*2, r*2);
    for theta=1:360
        a = round(r - r * cos(theta * pi / 180));
        b = round(r - r * sin(theta * pi / 180));
        circle_kernel(a+1,b+1) = 1;
    end
end
