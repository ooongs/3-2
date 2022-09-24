clear;
close all;
global R
global C
global res;

ball = imread('ball.jpg'); % 读取图像
[R,C,~] = size(ball);

init_res();
tmp = res;

imwrite(uint8(res),'Img28/bg.jpg','jpg');
% figure;
for i = 1:28
    move_img(ball,i*20,i*30);
%     imshow(uint8(res));
    imwrite(uint8(res),['Img28/',num2str(i),'.jpg'],'jpg');
    res = tmp;
end

function init_res()
global res;
global n;
n = 600;
res = zeros(n, 1.5*n, 3);
for i = 1:n
    for j = 1:1.5*n
        a = uint8(256);
        res(i,j,1:3)=[a,a,a];
    end
end
end

function move_img(A,x,y)
global res;
global R;
global C;
global n;  
tras = [1 0 x; 0 1 y; 0 0 1];
for i = 1 : R
    for j = 1 : C
        temp = [i; j; 1];
        temp = tras * temp;
        p = temp(1, 1);
        q = temp(2, 1);
        if (p <= n) && (q <= 1.5*n) && (p >= 1) && (q >= 1)
            res(p,q,:) = A(i,j,:);
        end
    end
end

end
