I = imread('coins.png');
EdgeMap1 = detectEdgesMatlab(I);
EdgeMap2 = detectEdgesConv(I);
HoughFindCircles(EdgeMap2);