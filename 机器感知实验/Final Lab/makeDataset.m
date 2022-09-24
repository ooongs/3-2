function dataset = makeDataset(img,mask)
img = double(img);
imgHSV = rgb2hsv(img);
imgYCbCr = rgb2ycbcr(img);
Hue = imgHSV(:,:,1)';
Cb = double(imgYCbCr(:,:,2));
Cr = double(imgYCbCr(:,:,3));

h = Hue(:);
cr = Cr(:)/240;
cb = Cb(:)/240;
m = mask';
m = double(m(:))/255;

dataset = [cr,cb,h,m];
end