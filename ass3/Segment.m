function [segmentation_array] = Segment(I)
    % magic #s
    n_labels = 24;
    max_iter = 10000;
    min_change = 10^-5;
    
    p_k = init_p_0(I, n_labels);
    s_k = calculate_support(p_k, size(I));
    
    p_k_next = calculate_p_k_next(p_k, s_k);
    
    delta = abs(p_k - p_k_next); % changes made
    
    iter = 1;
    while max(delta(:)) > min_change && iter < max_iter
        p_k = p_k_next;
        s_k = calculate_support(p_k, size(I));
        
        p_k_next = calculate_p_k_next(p_k, s_k);
        delta = abs(p_k - p_k_next); % changes made
        iter = iter + 1;
    end
    p_k = p_k_next;
    
    % select a label for the pixel
    labels = zeros(length(I(:)), 1);
    for i = 1:length(I(:))
        [~, sorted_idx] = sort(p_k(:,i),'descend');
        labels(i) = sorted_idx(1);
    end
    
    test = reshape(labels, size(I)) / n_labels;
    imshow(test);
    disp(iter);
end

function [p_0] = init_p_0(I, n_labels)
    [~, Gdir] = imgradient(I);
    
    % n_labels possible gradients
    I_first_label = round(mod(Gdir ./ (360 / n_labels), n_labels)) + 1;
    p_0 = zeros(length(I_first_label(:)), n_labels);
    
    % create prob window and set prob for each pixel
    probs_window = CreateWindow(n_labels);
    for i = 1:length(I_first_label(:))
        p_0(i,:) = circshift(probs_window, I_first_label(i) - 1);
    end
    
    p_0 = p_0';
end

function [w] = CreateWindow(size)
    % creates circular gaussian window with max at idx 1
    
    if mod(size,2) == 0
        w = sum(fspecial('gaussian', size + 1, 1));
        w = w(1:size);
    else
        w = sum(fspecial('gaussian', size, 1));
    end
    
    w = circshift(w, ceil(size / 2)); % moves max to idx 1
    
    sum_w = sum(w);
    w = w / sum_w;
end

function [s] = calculate_support(p_k, im_dim)
    % init
    [n_labels, n_pix] = size(p_k);
    raw_support = zeros(n_labels, n_pix);
    
    % calculate support for each pixel for label j using conv
    for j = 1: n_labels
        p_k_label = p_k(j,:);
        p_k_label = reshape(p_k_label, im_dim);
        ker = ones(3);
        support_row = conv2(p_k_label, ker, 'same');
        raw_support(j,:) = support_row(:);
    end
    s = raw_support;
    
end

function [p_k_next] = calculate_p_k_next(p_k, s_k)
    size_p_k = size(p_k);
    
    numerator = (p_k .* s_k);
    s_numerator = sum(numerator);
    denominator = ones(size_p_k);
    
    for i = 1:size_p_k(2)
        denominator(:,i) = s_numerator(i) * denominator(:,i);
    end
    
    p_k_next = numerator ./ denominator;
end