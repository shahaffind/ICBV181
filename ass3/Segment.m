function [segmentation_array] = Segment(I)
    
    n_labels = 24;

    p_0 = init_p_0(I, n_labels);

end

function [p_0] = init_p_0(I, n_labels)

    [~, Gdir] = imgradient(I);
    
    % n_labels possible gradients
    I_first_label = floor(mod(Gdir ./ (360 / n_labels), n_labels)) + 1;
    p_0 = zeros(length(I_first_label(:)), n_labels);
    
    probs_window = CreateWindow(n_labels);
    for i = 1:length(I_first_label(:))
        p_0(i,:) = circshift(probs_window, I_first_label(i) - 1);
    end
end

function [w] = CreateWindow(size)
        if mod(size,2) == 0
            w = sum(fspecial('gaussian', size + 1, 3));
            w = w(1:size);
            % max is centered around size/2 + 1
        else
            w = sum(fspecial('gaussian', size, 3));
            % max is centered around size/2 + 0.5
        end
        w = circshift(w, ceil(size / 2)); % moves max to idx 1
end