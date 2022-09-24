function [idx,C] = trainSkin(img,mode)
% Input
% img: RGB Image
% mode: 'Proposed'

% Output
% idx: Index of Clustered Image
% C: Centroid of Clusters

% RGB to Gray Scale
img_gray = rgb2gray(img);
% Get Otsu Threshold
Totsu = graythresh(img_gray)*255;
% Histogram
[n,~] = histcounts(img_gray,256);
[~,Tmax] = max(n);
% Calculate Threshold
if Tmax <= 10
	thres = round((Totsu+Tmax)/4);
else
    thres = round((Totsu+Tmax)/2);
end
% Binarize
mask_hist = uint8(zeros(size(img(:, :, 1))));
if Tmax <= 200
	mask_hist(img_gray > thres) = 1;
else
    mask_hist(img_gray < thres) = 1;
end
% Skin Segmentation
mask_skin = skinSeg(img,mode);
mask = mask_skin .* mask_hist;
% Make Dataset
dataset = makeDataset(img,mask);
% Train K-means
[idx,C] = kmeans(dataset,3,'MaxIter',100,'Distance','cityblock','Replicates',5,'Display','final');

% figure; imshow(logical(mask_hist));  
% figure; imshow(mask); 
end