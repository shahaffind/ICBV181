function [ ret_val ] = detectEdgesMatlab( I )
    Iedge_sobel = edge(I, 'sobel', 0.09);
    Iedge_log = edge(I,'log', 0.01);
    
    figure();
    imshow(Iedge_sobel);
    title('sobel edge detector');
    
    figure();
    imshow(Iedge_log);
    title('log edge detector');
    
    ret_val = Iedge_sobel;
end

