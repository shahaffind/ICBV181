function [segmentation_array] = Segment(I)
    % magic numbers
    n_labels = 24;
    max_iter = 1000;
    min_change = 10^-5;
    
    % init
    p_k = init_p_0(I, n_labels);
    s_k = calculate_support(p_k, size(I));
    p_k_next = calculate_p_next(p_k, s_k);
    
    delta = abs(p_k - p_k_next); % changes made for each pixel * label
    
    % loop until no significant change was made
    iter = 1;
    while max(delta(:)) > min_change && iter < max_iter
        p_k = p_k_next;
        s_k = calculate_support(p_k, size(I));
        p_k_next = calculate_p_next(p_k, s_k);
        
        delta = abs(p_k - p_k_next); % changes made for each pixel * label
        iter = iter + 1;
    end
    p_k = p_k_next;
    
    % for each pixel: select the label with the highest probability
    labels = zeros(length(I(:)), 1);
    for i = 1:length(I(:))
        [~, sorted_idx] = sort(p_k(:,i),'descend');
        labels(i) = sorted_idx(1);
    end
    
    % reshape into the image form
    segmentation_array = reshape(labels, size(I));
end

function [p_0] = init_p_0(I, n_labels)
    % calculate gradient
    [~, Gdir] = imgradient(I);
    
    % n_labels possible gradients
    I_first_label = round(mod(Gdir ./ (360 / n_labels), n_labels)) + 1;
    p_0 = zeros(n_labels, length(I_first_label(:)));
    
    % create prob window and set prob for each pixel
    probs_window = CreateWindow(n_labels);
    for i = 1:length(I_first_label(:))
        p_0(:,i) = circshift(probs_window, I_first_label(i) - 1);
    end
end

function [w] = CreateWindow(size)
    % creates circular gaussian window with max at idx 1
    
    if mod(size,2) == 0
        w = sum(fspecial('gaussian', size + 1, 2));
        w = w(1:size);
    else
        w = sum(fspecial('gaussian', size, 2));
    end
    
    w = circshift(w, ceil(size / 2)); % moves max to idx 1
    w = w / sum(w); % normalize to sum(w) = 1
end

function [s] = calculate_support(p_k, im_dim)
    % init
    [n_labels, n_pix] = size(p_k);
    s = zeros(n_labels, n_pix);
    ker = fspecial('gaussian', 7, 3);
    
    % calculate support for each pixel for label j using convolution
    for j = 1: n_labels
        p_k_label = p_k(j,:);
        p_k_label = reshape(p_k_label, im_dim);
        support_row = conv2(p_k_label, ker, 'same');
        s(j,:) = support_row(:);
    end
end

function [p_k_next] = calculate_p_next(p_k, s_k)
    numerator = (p_k .* s_k);
    
    % normalize for each pixel: sum of probs = 1
    p_k_next = numerator ./ sum(numerator);
end
