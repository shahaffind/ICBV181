function [ A ] = HoughFindCircles( I_edge )
    
    a_max = length(I_edge(1,:));
    b_max = length(I_edge(:,1));
    r_max = min(a_max, b_max) / 2;

    nz = find(I_edge);
    [nz_x, nz_y] = ind2sub(size(I_edge),nz);
    
    % dims: x_0, y_0, r
    A = zeros(a_max, b_max, r_max);
    
    for i=1:length(nz_x)
        for r=1:r_max
            votes = vote_for(nz_x(i), nz_y(i), r, a_max, b_max);
            A(:,:,r) = A(:,:,r) + votes;
        end
    end
    
    imshow(I_edge);
    [sortedA, sortedInds] = sort(A(:),'descend');
    top_votes = sortedInds(1:25);
    [Y,X,R] = ind2sub(size(A), top_votes);
    viscircles([X Y], R);
    title('hough circle detection');
end

function [vote_metrix] = vote_for(x, y, r, a_max, b_max)
    vote_metrix = zeros(a_max, b_max);
    for theta=1:360
        a = round(x - r * cos(theta * pi / 180));
        b = round(y - r * sin(theta * pi / 180));
        if a > 0 && b > 0 && a < a_max && b < b_max
            vote_metrix(a,b) = 1;
        end
    end
end