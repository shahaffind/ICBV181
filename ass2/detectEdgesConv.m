function [ ret_val ] = detectEdgesConv( I )
    
    gx = [-1 -2 -1 ; 0 0 0 ; 1 2 1];
    gy = [-1 0 1 ; -2 0 2 ; -1 0 1];
    
    Ix = conv2(I, gx);
    Iy = conv2(I, gy);
    
    Ig = sqrt(Ix .^ 2 + Iy .^ 2);
    
    % normalize
    max_val = max(Ig(:));
    min_val = min(Ig(:));
    
    Ig_norm = (Ig - min_val) ./ (max_val - min_val);
    
    % binary over threshold
    I_edge = arrayfun(@(x) x > 0.25, Ig_norm);
    
    % check if needed
    figure();
    imshow(I_edge);
    
    ret_val = I_edge;
end
