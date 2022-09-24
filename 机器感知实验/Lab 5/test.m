clear;
clc;
close all;

img = imread('lena.tif');

n = "gaussian";
% n = "salt & pepper";
% n = "speckle";
noise = imnoise(img,n);
%%
% p = zeros(2,21);
% for i = 0:20
%     d = 50+i*5;
% %     enhanced4 = lowpassFilter(noise,d);
%     enhanced4 = blpfFilter(noise,d,3);
%     p(:,i+1) = [d PSNR(img,enhanced4)]
% end
% p0 = PSNR(img,noise);
% plot(p(1,:),p(2,:),"*")

%%
% d = 80;
% a = sqrt(2)-1;
% for i=0:10
%     h = zeros(2,101);
%     n=2^i
%     c = 1;
%     for j=0:0.05:5
%         tmp=1/(1+a*(j)^(2*n));
%         h(:,c) = [j tmp];
%         c = c + 1;
%     end
%     hold on
%     plot(h(1,:),h(2,:))
% %     legend("n = "+string(n))
% end
% for i=1:10
%     n=2^i;
%     legend("n = "+string(n))
% end
%%
% enhanced1 = meanFilter(noise);
% enhanced2 = medianFilter(noise);
enhanced3 = lowpassFilter(noise,70);
enhanced4 = blpfFilter(noise,75,3);

% figure
% imshow(img);
% 
% figure;
% imshow(noise);
% 
% figure;
% subplot(321); imshow(img); title("Original")
% subplot(322); imshow(noise); title(n)
% subplot(323); imshow(enhanced1); title("Mean Filter")
% subplot(324); imshow(enhanced2); title("Median Filter")
% subplot(325); imshow(enhanced3); title("Low Pass Filter")
% subplot(326); imshow(enhanced4); title("BLPF")
% 
% p0 = PSNR(img,noise);
% p1 = PSNR(img,enhanced1);
% p2 = PSNR(img,enhanced2);
% p3 = PSNR(img,enhanced3);
% p4 = PSNR(img,enhanced4);



figure;
imgFFT = fftshift(fft2(double(img)));
subplot(121); imshow(log(abs(imgFFT)),[]); title("原始图像的频谱图")
subplot(122); mesh(log(abs(imgFFT))); title("原始图像的频谱透视图")

figure;
imgFFT = fftshift(fft2(double(noise)));
subplot(121); imshow(log(abs(imgFFT)),[]); title("含噪图像的频谱图")
subplot(122); mesh(log(abs(imgFFT))); title("含噪图像的频谱透视图")

figure;
imgFFT = fftshift(fft2(double(enhanced3)));
subplot(121); imshow(log(abs(imgFFT)),[]); title("增强图像的频谱图")
subplot(122); mesh(log(abs(imgFFT))); title("增强图像的频谱透视图")

figure;
imgFFT = fftshift(fft2(double(enhanced4)));
subplot(121); imshow(log(abs(imgFFT)),[]); title("增强图像的频谱图")
subplot(122); mesh(log(abs(imgFFT))); title("增强图像的频谱透视图")


function img_out = meanFilter(A)
img_out = A;
[R,C] = size(A);
for i = 1:R
	for j = 1:C
        u = max(i-1,1);
        d = min(i+1,R);
        l = max(j-1,1);
        r = min(j+1,C);
        img_out(i,j) = mean(mean(A(u:d,l:r)));
	end
end
end

function img_out = medianFilter(A)
img_out = A;
[R,C] = size(A);
for i = 1:R
    for j = 1:C
        u = max(i-1,1);
        d = min(i+1,R);
        l = max(j-1,1);
        r = min(j+1,C);
        a = A(u:d,l:r);
        a = a(:);
        img_out(i,j) = median(a);
    end
end
end

function img_out = lowpassFilter(A,d0)
imgFFT = fftshift(fft2(double(A)));
[R,C] = size(A);
r0 = round(R/2); 
c0 = round(C/2);  
img_out = zeros(R,C);
d0 = d0^2;
for i = 1:R
    tmp = zeros(1,C);
    for j = 1:C
        d = (i-r0)^2+(j-c0)^2;
        if d <= d0
            h = 1;
        else
            h = 0;
        end
        tmp(j) = h*imgFFT(i,j);
    end
    img_out(i,:) = tmp;
end

img_out = ifftshift(img_out);
img_out = uint8(real(ifft2(img_out)));
end

function img_out = blpfFilter(A,d0,n)
imgFFT = fftshift(fft2(double(A)));
[R,C] = size(A);
r0 = round(R/2); 
c0 = round(C/2);  
img_out = zeros(R,C);
d0 = d0^(2*n);
a = sqrt(2)-1;
for i = 1:R
    for j = 1:C
        d = (i-r0)^2+(j-c0)^2;
        h = 1 / (1+a*(d^n)/d0);  
        img_out(i,j) = h*imgFFT(i,j);
    end
end

img_out =ifftshift(img_out);
img_out = uint8(real(ifft2(img_out)));
end


function psnr = PSNR(img,noise)
[n,m] = size(img);
img1 = double(img);
img2 = double(noise);
MAXI = 255;
MSE = sum(sum((img1-img2).^2))/(m*n);
psnr = 20*log10(MAXI/sqrt(MSE));
end
