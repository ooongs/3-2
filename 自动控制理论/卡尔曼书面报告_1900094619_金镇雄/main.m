clear;
clear TrackKalmanQR;
clear TrackKalman;
clear GetBallPos;
close all;
global random;
global r1;
global r2;

NoOfImg = 58;
Xmsaved  = zeros(2, NoOfImg);
Xhsaved  = zeros(2, NoOfImg);
Xqrsaved = zeros(2, NoOfImg);
Xsaved = zeros(2,NoOfImg);
random = 25*randn(size(Xsaved));
r1 = cov(random(1,:));
r2 = cov(random(2,:));

for k = 1:NoOfImg
  [xm, ym,x,y] = Tracker(k);
  [xh, yh] = Kalman(xm, ym);
  figure(1);
  hold on
  plot(xm, ym, 'r*')
  plot(xh, yh, 'bs')
  
  pause(1)
  
  Xmsaved(:, k) = [xm ym]';
  Xhsaved(:, k) = [xh yh]';
  Xsaved(:,k) = [x y]';
end

figure
hold on
plot(Xhsaved(1,:), Xhsaved(2,:), 'b')
plot(Xmsaved(1,:), Xmsaved(2,:), 'r')
plot(Xsaved(1,:),Xsaved(2,:),'k')
plot(Xhsaved(1,:), Xhsaved(2,:), 'bs')
plot(Xmsaved(1,:), Xmsaved(2,:), 'r*')
plot(Xsaved(1,:),Xsaved(2,:),'k+')

legend('滤波轨迹','观测轨迹','实际轨迹')