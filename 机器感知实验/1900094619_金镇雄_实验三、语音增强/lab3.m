function varargout = lab3(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lab3_OpeningFcn, ...
                   'gui_OutputFcn',  @lab3_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before lab3 is made visible.
function lab3_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for lab3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = lab3_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in browse_button.
function browse_button_Callback(hObject, eventdata, handles)
global audio;
global fs;
global file;
[file,~] = uigetfile('*.wav','请选择语音文件：');         % 选择音频样本
[audio,fs] = audioread(file);   % 读入音频信息
set(handles.original_sound,'value',1);
set(handles.audio_file,'String',file);

function audio_file_Callback(hObject, eventdata, handles)
global file;
file = get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function audio_file_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in noise_type.
function noise_type_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function noise_type_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'value',1);

% --- Executes on slider movement.
function snr_slider_Callback(hObject, eventdata, handles)
global snr;
snr = get(hObject,'Value')-5;
set(handles.snr_text,'String',num2str(snr));

% --- Executes during object creation, after setting all properties.
function snr_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Value',5)

function snr_text_Callback(hObject, eventdata, handles)
global snr;
input = str2double(get(hObject,'String'));
if input <= 5 && input >= -5
    snr = input;
    set(handles.snr_slider,'Value',snr+5);
else
    msgbox('Invalid Value: -5 <= SNR <= 5','warning','warn'); %error message window
end

% --- Executes during object creation, after setting all properties.
function snr_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global snr;
snr = 0;
set(hObject,'string','0');

% --- Executes on button press in confirm_button.
function confirm_button_Callback(hObject, eventdata, handles)
global audio;
global noisy;
global enhanced;
global snr;
global fs;

st = 2;                         % 静音段长度(s)
sil_frame = zeros(fs,1);        
tmp_audio = [sil_frame;audio];      % 在音频信号前端加静音段

if get(handles.noise_type,'value') == 1
    noisy = awgn(tmp_audio,snr,'measured');
elseif get(handles.noise_type,'value') == 2
    noisy = add_noise(tmp_audio,fs,'SSN.wav',snr);
elseif get(handles.noise_type,'value') == 3
    noisy = add_noise(tmp_audio,fs,'pink_noise.wav',snr);
else
    noisy = awgn(tmp_audio,snr,'measured');
end


win_len = 200;
overlap = 120;
win = hamming(win_len); 
inc = win_len - overlap;

nSilence = fix((st*fs-win_len)/inc +1);                 % 静音段帧数
nframe = floor((length(noisy) - win_len) / inc) + 1;    % 信号帧数

% 计算噪声幅度
hfreq = win_len/2+1;
noise_energy = zeros(hfreq,1);
for k = 1 : nSilence
    tmp = noisy((1:win_len) + (k-1) * inc).*win;
    tmp_fft = fft(tmp);
    noise_energy = noise_energy + abs(tmp_fft(1:hfreq)).^2;
end
noise_energy_avg = noise_energy / nSilence;

% berouti参数设定
alpha = 1;  % 相减因子
beta = 0;   % 频谱下限阈值参数
if get(handles.berouti_button,'value') == 1
    alpha = 4-snr*3/20
    if snr >= 0
        beta = 0.003
    else
        beta = 0.02
    end
end

% 增强语音
enhanced = zeros((nframe-1)*inc+win_len,1);
for k = 1 : nframe
    % 分帧
    tmp = noisy((1:win_len) + (k-1) * inc).*win;
    tmp_fft = fft(tmp);
    
    audio_phase = angle(tmp_fft(1:hfreq));      % 保留信号相位
    audio_energy = abs(tmp_fft(1:hfreq)).^2;    % 计算每帧能量
    
    % 谱减（减去估计噪声）
    sub_energy = zeros(hfreq,1);
    for m = 1:hfreq 
       if  audio_energy(m) >= (alpha+beta) * noise_energy_avg(m)
           sub_energy(m) = audio_energy(m) - alpha * noise_energy_avg(m);
       else
           sub_energy(m) = beta * noise_energy_avg(m);
       end
    end
    
    % 取根号
    abs_freq = sqrt(sub_energy);
    
    % 加相位信息
    audio_freq = abs_freq .* exp(1j*audio_phase);
    
    % 上下翻转
    tmp_freq = [audio_freq ; conj(audio_freq(end-1:-1:2))];
    
    % ifft
    tpm_time = real(ifft(tmp_freq));
    
    % 帧合并
    s=(k-1)*inc+1;
    enhanced(s:s+win_len-1)=enhanced(s:s+win_len-1) + tpm_time;
end

% N = length(tmp_audio);
% N1=2^nextpow2(N);
% f1=fft(tmp_audio,N1);
% f2=fft(noisy,N1);
% f3=fft(enhanced,N1);
% f1=f1(1:N1/2);
% f2=f2(1:N1/2);
% f3=f3(1:N1/2);
% x1=abs(f1);
% x2=abs(f2);
% x3=abs(f3);
% p1=phase(f1);
% p2=phase(f2);
% p3=phase(f3);
% f=fs*(0:N1/2-1)/N1; %Frequency axis
% 
% figure;
% subplot(311)
% plot(tmp_audio); title("Time - Original Signal")
% subplot(312)
% plot(noisy); title("Time - Noisy Signal(White Gausian)")
% subplot(313)
% plot(enhanced); title("Time - Enhanced Signal(Berouti)")
% 
% figure;
% subplot(311)
% plot(f,(x1/N1));
% xlabel('Frequency (Hz)'); ylabel('Magnitude Spectrum');
% title("Magnitude - Original Signal")
% subplot(312)
% plot(f,(x2/N1));
% xlabel('Frequency (Hz)'); ylabel('Magnitude Spectrum');
% title("Magnitude - Noisy Signal(White Gausian)")
% subplot(313)
% plot(f,(x3/N1));
% xlabel('Frequency (Hz)'); ylabel('Magnitude Spectrum');
% title("Magnitude - Enhanced Signal(Berouti)")
% 
% figure;
% subplot(311)
% plot(f,p1);
% xlabel('Frequency (Hz)'); ylabel('Phase Spectrum');
% title("Phase - Original Signal")
% subplot(312)
% plot(f,p2);
% xlabel('Frequency (Hz)'); ylabel('Phase Spectrum');
% title("Phase - Noisy Signal(White Gausian)")
% subplot(313)
% plot(f,p3);
% xlabel('Frequency (Hz)'); ylabel('Phase Spectrum');
% title("Phase - Enhanced Signal(Berouti)")

function y = add_noise(x,fs,type,SNR)
% add_noisem add determinated noise to a signal.
% X is signal, and its sample frequency is fs;
[n,fs1] = audioread(type);
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

% --- Executes on button press in original_sound.
function original_sound_Callback(hObject, eventdata, handles)
set(handles.original_sound,'value',1);
set(handles.noisy_sound,'value',0);
set(handles.enhanced_sound,'value',0);

% --- Executes on button press in noisy_sound.
function noisy_sound_Callback(hObject, eventdata, handles)
set(handles.original_sound,'value',0);
set(handles.noisy_sound,'value',1);
set(handles.enhanced_sound,'value',0);

% --- Executes on button press in enhanced_sound.
function enhanced_sound_Callback(hObject, eventdata, handles)
set(handles.original_sound,'value',0);
set(handles.noisy_sound,'value',0);
set(handles.enhanced_sound,'value',1);

% --- Executes on button press in play_button.
function play_button_Callback(hObject, eventdata, handles)
global audio;
global noisy;
global enhanced;
global fs;
global player;

if get(handles.original_sound,'value')
    player = audioplayer(audio,fs);
elseif get(handles.noisy_sound,'value')
    player = audioplayer(noisy,fs);
elseif get(handles.enhanced_sound,'value')
    player = audioplayer(enhanced,fs);
end
player.play;


% --- Executes on button press in berouti_button.
function berouti_button_Callback(hObject, eventdata, handles)
    set(handles.berouti_button,'value',1);