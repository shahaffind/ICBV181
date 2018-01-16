load('GradWorld-1.mat');
figure();
fprintf('Segmenting GradWorld1...\n');
segmented = Segment(I);
imshow(segmented / 24);
title('GradWorld1');

figure();
I = imnoise(I, 'salt & pepper', 0.2);
fprintf('Segmenting GradWorld1 S&P...\n');
segmented = Segment(I);
imshow(segmented / 24);
title('GradWorld1 Salt & Pepper');

load('GradWorld-2.mat');
figure();
fprintf('Segmenting GradWorld2...\n');
segmented = Segment(I);
imshow(segmented / 24);
title('GradWorld2');

figure();
I = imnoise(I, 'salt & pepper', 0.2);
fprintf('Segmenting GradWorld2 S&P...\n');
segmented = Segment(I);
imshow(segmented / 24);
title('GradWorld2 Salt & Pepper');

load('GradWorld-3.mat');
figure();
fprintf('Segmenting GradWorld3\n');
segmented = Segment(I);
imshow(segmented / 24);
title('GradWorld3');

figure();
I = imnoise(I, 'salt & pepper', 0.2);
fprintf('Segmenting GradWorld3 S&P...\n');
segmented = Segment(I);
imshow(segmented / 24);
title('GradWorld3 Salt & Pepper');