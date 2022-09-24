%[file,~] = uigetfile('*.wav','请选择语音文件：')
clc; clear all; close all;

[audio,fs] = audioread('speech.wav');
x = add_SSN(audio,fs,5);
%x = awgn(audio,5,'measured','linear');

IS = 1.6;      % 设置前导无话段长度 [s]
wlen = 200;    % 务必设置为偶数个点
inc = 80;
win = hamming(wlen); % 用矩形窗，也会有问题-_-!


N=length(x);                            % 信号长度
time=(0:N-1)/fs;                        % 设置时间
overlap=wlen-inc;                       % 求重叠区长度
NIS=fix((IS*fs-wlen)/inc +1);           % 求前导无话段帧数
Nframe = floor( (length(x) - wlen) / inc) + 1; % 一共多少帧

k_pos_freq = wlen/2+1; % 非负频率范围
X_noise_engergy_sum = zeros(k_pos_freq,1);

for k = 1 : NIS
    idx = (1:wlen) + (k-1) * inc;
    x_temp = x(idx).*win;
    X_temp = fft(x_temp);
    X_noise_engergy_sum = X_noise_engergy_sum + abs(X_temp(1:k_pos_freq)).^2;
end
X_noise_engergy_avg = X_noise_engergy_sum / NIS;
a = 10;
b = 0.002;
sig=zeros((Nframe-1)*inc+wlen,1);
for k = 1 : Nframe
    idx = (1:wlen) + (k-1) * inc;
    x_temp = x(idx).*win;
    X_temp = fft(x_temp);
    phase_k = angle(X_temp(1:k_pos_freq)); % 1. 先保留信号的相位
    X_energy = abs(X_temp(1:k_pos_freq)).^2;
    
    X_subspec_energy_pos_freq = zeros(k_pos_freq,1); % 谱减以后，非负频率分量的能量
    for m = 1:k_pos_freq % 对每一个频点进行谱减
       if  X_energy(m) >= a * X_noise_engergy_avg(m)
           X_subspec_energy_pos_freq(m) = X_energy(m) - a * X_noise_engergy_avg(m);
       else
           X_subspec_energy_pos_freq(m) = b * X_noise_engergy_avg(m);
       end
    end
    
    X_subspec_abs_pos_freq = sqrt(X_subspec_energy_pos_freq);
    X_subspec_pos_freq = X_subspec_abs_pos_freq .* exp(1j*phase_k); % A = |A|exp(1j*angle(A))
    % 构造Hermitian对称的序列
    X_subspec_at_frame_k = [X_subspec_pos_freq ; conj(X_subspec_pos_freq(end-1:-1:2))];
    x_subspec_at_frame_k = real(ifft(X_subspec_at_frame_k));
    start=(k-1)*inc+1;    
    sig(start:start+wlen-1)=sig(start:start+wlen-1) + x_subspec_at_frame_k; % 重叠相加
end
plot(audio);
figure;
plot(x);
figure;
plot(sig);
player = audioplayer(sig,fs);
player.play;


function y = add_SSN(x,fs,SNR)
% add_noisem add determinated noise to a signal.
% X is signal, and its sample frequency is fs;
[n,fs1] = audioread('SSN.wav');
if fs1~=fs
    tmp = resample(n,fs,fs1);
end
nx = size(x,1);
xlen = length(x);
tlen = length(tmp);
if xlen < tlen
    noise = tmp(1:nx);
elseif xlen == tlen
    noise = tmp;
else
    a = floor(xlen / tlen);
    m = mod(xlen,tlen);
    noise = [];
    for i = 1:a
        noise = [noise;tmp];
    end
    noise = [noise;tmp(1:m)];
end
noise = noise - mean(noise);
signal_power = 1/nx*sum(x.*x);
noise_variance = signal_power / ( 10^(SNR/10) );
noise=sqrt(noise_variance)/std(noise)*noise;
y = x + noise;
end