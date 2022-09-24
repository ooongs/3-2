clc; clear;
global res;
global img;
global R;
global C;
global p;
global q;
global tmp;
init = imread('pic/img2.jpg'); % 读取图像
tmp = init;
img = init;
[R, C,~] = size(init); % 获取图像大小
% init_res();
% [p,q] = move_img(init,0,0);
% figure(2);
figure(1);
manhua()
imshow(uint8(res)); % 显示图像
imwrite(uint8(init),'1.jpg','jpg');
figure;
imshow(double(img))
imwrite(double(img),'2.jpg','jpg');
% init_res();

% sh_img(init,0.8,0.8)
% times_img(init,1,1)
% imshow(uint8(res)); % 显示图像

function manhua()
global img;
global res;
global R;
global C;
global p;
global q;
for i = 1 : R
    for j = 1 : C
        r = (img(i,j,1));
        g = (img(i,j,2));
        b = (img(i,j,3));
        r_ = uint8(abs(g-b+g+r)*r/256);
        g_ = uint8(abs(b-g+b+r)*r/256);
        b_ = uint8(abs(b-g+b+r)*g/256);
        if r_ < 0
            r_ = 0;
        elseif r_ > 255
            r_ = 255;
        end
        if g_ < 0
            g_ = 0;
        elseif g_ > 255
            g_ = 255;
        end
        if b_ < 0
            b_ = 0;
        elseif b_ > 255
            b_ = 255;
        end
        img(i,j,:) = [r_, g_, b_];
        res(p+i,q+j,:) = [r_, g_, b_];
    end
end
end
%%
% init_res();
% rotate_img(init,p,q,310)
% figure(1);
% imshow(uint8(res)); % 显示图像
% figure(2);
% imshow(uint8(tmp))
function init_res()
global res;
res = zeros(800, 800, 3);
for i = 1:800
    for j = 1:800
        res(i,j,1:3)=[256,256,256];
    end
end
end

function sh_img(A,shx,shy)
global R;
global C;
global res;
sh = [1 shy 0; shx 1 0; 0 0 1]';
global p;
global q;
for i = -round(R + shx*C) : 1 : 2*R + shx * C
    for j = -round(C + shy * R) : 1 : 2*C + shy * R - 20
        temp = [i; j; 1];
        temp = sh * temp; % 矩阵乘法
        x = uint16(temp(1, 1));
        y = uint16(temp(2, 1));
        % 变换后的位置判断是否越界
        if (x <= R) && (y <= C) && (x >= 1) && (y >= 1)
            if (p+i <= 800) && (q+j <= 800) && (p+i >= 1) && (q+j >= 1)
                res(p+i, q+j,:) = A(x, y,:);
            end
        end
    end
end

end

function times_img(A,sx,sy)
global p;
global q;
global R;
global C;
global res;
% tmp = zeros(sx * R, sy * C); % 构造结果矩阵。每个像素点默认初始化为0（黑色）
tras = [1/sx 0 0; 0 1/sy 0; 0 0 1] % 缩放的变换矩阵 
p = p-(R*(sx-1))/2;
q = q-(C*(sy-1))/2;
for i = 1 : sx * R
    for j = 1 : sy * C
        temp = [i; j; 1];
        temp = tras * temp; % 矩阵乘法
        x = uint8(temp(1, 1));
        y = uint8(temp(2, 1));
        % 变换后的位置判断是否越界
        if (x <= R) && (y <= C) && (x >= 1) && (y >= 1)
            if (p+i <= 500) && (q+j <= 500) && (p+i >= 1) && (q+j >= 1)
                res(p+i, q+j,:) = A(x, y,:);
            end
        end
    end
end
end

function [a,b] = move_img(A,x,y)
global res;
global R;
global C;
delX = round(800/2)-round(R/2)+x; % 平移量X
delY = round(800/2)-round(C/2)+y; % 平移量Y
tras = [1 0 delX; 0 1 delY; 0 0 1]; % 平移的变换矩阵 
for i = 1 : R
    for j = 1 : C
        temp = [i; j; 1];
        temp = tras * temp; % 矩阵乘法
        p = temp(1, 1);
        q = temp(2, 1);
        % 变换后的位置判断是否越界
        if (p <= 800) && (q <= 800) && (p >= 1) && (q >= 1)
            res(p,q,:) = A(i,j,:);
        end
    end
end
a = delX;
b = delY;
end

function rotate_img(A,p,q,d)
global res;
global tmp;
global R;
global C;
alpha = d * 3.1415926 / 180.0; % 旋转角度
c1 = round(-R*sin(alpha));
c2 = round(C*cos(alpha));
r1 = round(C*sin(alpha));
r2 = round(R*cos(alpha));
if cos(alpha)*sin(alpha) >= 0
    if c1 > c2
        j1 = c2;
        j2 = c1;
    else
        j1 = c1;
        j2 = c2;
    end
    if r1+r2 > 0
        i1 = 0;
        i2 = r1+r2;
    else
        i1 = r1+r2;
        i2 = 0;
    end
else
    if c1+c2 < 0
        j1 = c1+c2;
        j2 = 0;
    else
        j1 = 0;
        j2 = c1+c2;
    end
    if r1 > r2
        i1 = r2;
        i2 = r1;
    else
        i1 = r1;
        i2 = r2;
    end
end
a = abs(i1)+abs(i2);
b = abs(j1)+abs(j2);
tmp = zeros(a,b,3);
tras = [cos(alpha) -sin(alpha) 0; sin(alpha) cos(alpha) 0; 0 0 1]; % 旋转的变换矩阵

for i = i1 : i2
    for j = j1 : j2
        temp = [i; j; 1];
        temp = tras * temp;% 矩阵乘法
        x = uint16(temp(1, 1));
        y = uint16(temp(2, 1));
        % 变换后的位置判断是否越界
        if (x <= R) && (y <= C) && (x >= 1) && (y >= 1)
            tmp(i-i1+1,j-j1+1,:) = A(x,y,:);
            if (p+i <= 800) && (q+j <= 800) && (p+i >= 1) && (q+j >= 1)
                res(p+i,q+j,:) = A(x,y,:); 
            end
        else
            tmp(i-i1+1,j-j1+1,:) = [128,0,0];
            if (p+i <= 800) && (q+j <= 800) && (p+i >= 1) && (q+j >= 1)
                res(p+i,q+j,:) = [128,0,0];
            end
        end
    end
end
end