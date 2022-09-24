function [xc, yc, x, y] = Tracker(index)
persistent bg
persistent firstRun
global random

if isempty(firstRun)
  bg = imread('Img/bg.jpg');
  firstRun = 1;
end

img = imread(['Img/', int2str(index), '.jpg']); 
imshow(img)

fg = imabsdiff(img, bg);
fg = (fg(:,:,1) > 10) | (fg(:,:,2) > 10) | (fg(:,:,3) > 10);

stats = regionprops(logical(fg), 'area', 'centroid');
area_vector = [stats.Area];
[~, idx] = max(area_vector);
centroid = stats(idx(1)).Centroid;

% 实际位置
x = centroid(1);
y = centroid(2);

% 观测位置（含噪声）
xc = centroid(1) + random(1,index);
yc = centroid(2) + random(2,index);

  