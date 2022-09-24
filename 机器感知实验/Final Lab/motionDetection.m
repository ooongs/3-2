function [bw] = motionDetection(img,prev_img)
% Frame Difference
Fdt = abs(img - prev_img);

% rgb2gray
R = Fdt(:, :, 1);
G = Fdt(:, :, 2);
B = Fdt(:, :, 3);
Fdg = 0.299*R + 0.587*G + 0.114*B;  

% calculate T
X = mean(Fdg, 'all');
T = 0.05 * X;    

Q = imbinarize(Fdg,T); % D(t,t+1)

% Morphological Image Processing
se = strel('square',5);

bw = imopen(Q,se);
bw = imclose(bw,se);
bw = imfill(bw,'holes');
bw = imclearborder(bw,4);
bw = bwareaopen(bw,300);
end

