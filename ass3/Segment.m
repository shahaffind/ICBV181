function [segmentation_array] = Segment(I)
    % magic #s
    n_labels = 24;
    
    p_k = init_p_0(I, n_labels);
    s_k = calculate_support(p_k, size(I));
    m_1 = ones(size(p_k));
    
    % normalize probabilities
    numerator = p_k .* s_k;
    s_numerator = sum(numerator);
    denominator = m_1;
    for i = 1:length(I(:))
        denominator(:,i) = s_numerator(i) * m_1(:,i);
    end
    
    p_k_next = numerator ./ denominator;
    delta = abs(p_k - p_k_next); % changes made
    
    iter = 1;
    while (max(delta(:)) > (0.00001) && iter < 1000)
        p_k = p_k_next;
        s_k = calculate_support(p_k, size(I));
        
        % normalize probabilities
        numerator = (p_k .* s_k);
        s_numerator = sum(numerator);
        denominator = m_1;
        for i = 1:length(I(:))
            denominator(:,i) = s_numerator(i) * m_1(:,i);
        end
        p_k_next = numerator ./ denominator;
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
    
    test = reshape(labels, size(I)) / 24;
    imshow(test);
end

function [p_0] = init_p_0(I, n_labels)
    [~, Gdir] = imgradient(I);
    
    % n_labels possible gradients
    I_first_label = floor(mod(Gdir ./ (360 / n_labels), n_labels)) + 1;
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
    [n_labels, n_pix] = size(p_k);
    s = zeros(n_labels, n_pix);
    
    for j = 1: n_labels
        p_k_label = p_k(j,:);
        p_k_label = reshape(p_k_label, im_dim);
%         ker = fspecial('gaussian', 5, 1);
%         ker = ker / ker(3,3);
        ker = ones(3);
        support_label = conv2(p_k_label, ker);
        support_label = support_label(2:im_dim(1)+1, 2:im_dim(2)+1); %trim
        s(j,:) = support_label(:);
    end
    
end