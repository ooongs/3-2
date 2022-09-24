function [xh, yh] = Kalman(xm, ym)
persistent A H Q R
persistent X P
persistent firstRun
global r1;
global r2;

if isempty(firstRun)
    % 采样周期
    dt = 1;
    % 
    A = [ 1  dt  0   0
          0  1   0   0
          0  0   1  dt
          0  0   0   1 ];
    %
    H = [ 1  0  0  0
          0  0  1  0 ];
    %
    Q = 0.01*eye(4);
    %
    R = [r1 0
         0  r2];
    %
    X = [0, 0, 0, 0]';
    %
    P = 100*eye(4);
  
  firstRun = 1;
end

% 状态一步预测
Xk_ = A*X;

% 一步预测均方误差
Pk_ = A*P*A' + Q;

% 滤波增益
K = Pk_*H'*inv(H*Pk_*H' + R);

% 观测值
z = [xm ym]';

% 状态估计
X = Xk_ + K*(z - H*Xk_);

% 估计均方误差
P = Pk_ - K*H*Pk_;

xh = X(1);
yh = X(3);