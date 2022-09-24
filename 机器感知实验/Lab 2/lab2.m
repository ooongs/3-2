function varargout = lab2(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lab2_OpeningFcn, ...
                   'gui_OutputFcn',  @lab2_OutputFcn, ...
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

function lab2_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for lab2
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

function varargout = lab2_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes on button press in select_button.
function select_button_Callback(hObject, eventdata, handles)
global audio;
global fs;
[file,~] = uigetfile();         % 选择音频样本
[audio,fs] = audioread(file);   % 读入音频信息

function [closest_loc,second_loc,dist_arr] = find_closest(azi,elev,dist)
prev_azi = azi;
prev_elev = elev;
prev_dist = dist;
dist_list = [20 30 40 50 75 100 130 160];

if dist < 20
    dist = 20;
end
if dist > 160
    dist = 160;
end
if elev < -40
    elev = -40;
end
if elev > 90
    elev = 90;
end
if azi < 0
    azi = 0;
end
if azi > 360
    azi = 360;
end

% 找最近位置的dist
for i = 1:7
    if dist >= dist_list(i) && dist <= dist_list(i+1) 
        if dist < (dist_list(i+1) + dist_list(i))/2
            dist = dist_list(i);
        else
            dist = dist_list(i+1);
        end
        break;
    end
end

% 找最近位置的elev
elev = 10*round(elev/10);

% 找最近两个位置的azi
if elev >= -40 && elev <= 50
    azi = floor(azi/5)*5;
    second_azi = azi;
    if mod(round(azi),5) >= 3
        azi = azi+5;
    else
        second_azi = azi+5;
    end
elseif elev == 60 
    azi = floor(azi/10)*10;
    second_azi = azi;
    if mod(round(azi),10) >= 5
        azi = azi+10;
    else
        second_azi = azi+10;
    end
elseif elev == 70
    azi = floor(azi/15)*15;
    second_azi = azi;
    if mod(round(azi),15) >= 8
        azi = azi+15;
    else
        second_azi = azi+15;        
    end
elseif elev == 80
    azi = floor(azi/30)*30;
    second_azi = azi;    
    if mod(floor(azi),30) >= 15
        azi = azi+30;
    else
        second_azi = azi+30;
    end
elseif elev == 90
    if azi <= 180
        azi = 0;
        second_azi = 360;    
    else 
        azi = 360;
        second_azi = 0;
    end
end
% 最近两个点的位置
closest_loc = [azi;elev;dist];
second_loc = [second_azi;elev;dist];
% 计算距离
rel_dist = relative_dist(prev_azi,prev_elev,prev_dist,azi,elev,dist);
sec_dist = relative_dist(prev_azi,prev_elev,prev_dist,second_azi,elev,dist);
dist_arr = [rel_dist,sec_dist];

% 计算距离
function res = relative_dist(azi1,elev1,dist1,azi2,elev2,dist2)
x1 = dist1*cos(azi1)*sin(elev1);
y1 = dist1*sin(azi1)*sin(elev1);
z1 = dist1*cos(elev1);
x2 = dist2*cos(azi2)*sin(elev2);
y2 = dist2*sin(azi2)*sin(elev2);
z2 = dist2*cos(elev2);
res = sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2);

% --- Executes on button press in update_static_button.
function update_static_button_Callback(hObject, eventdata, handles)
global st_azi;              % 静态虚拟声音的azi（在GUI界面用户通过slider或editable text给的）
global st_elev;             % 静态虚拟声音的elev
global st_dist;             % 静态虚拟声音的dist

% 找与给定位置最近的HRTF数据库测量点位置
[st,~,~] = find_closest(st_azi,st_elev,st_dist); 
st_azi = st(1);
st_elev = st(2);
st_dist = st(3);

% 修改slider位置和text值
set(handles.static_azi,'String',num2str(st_azi));
set(handles.azi_slider,'Value',st_azi);
set(handles.static_elev,'String',num2str(st_elev));
set(handles.elev_slider,'Value',st_elev+40);
set(handles.static_dist,'String',num2str(st_dist));
set(handles.dist_slider,'Value',st_dist-20);

% 静态虚拟声音合成

global output;
global audio;
tmp_audio = audio';
% 读取与给定位置对应的HRIR数据
lf = sprintf('PKU-IOA HRTF database\\dist%d\\elev%d\\azi%d_elev%d_dist%d.dat',st_dist,st_elev,st_azi,st_elev,st_dist);      % 左耳
rf = sprintf('PKU-IOA HRTF database\\dist%d\\elev%d\\azi%d_elev%d_dist%d.dat',st_dist,st_elev,360-st_azi,st_elev,st_dist);  % 右耳
lfid = fopen(lf,'r');   l_hrir = fread(lfid,1024,'double');
rfid = fopen(rf,'r');   r_hrir = fread(rfid,1024,'double');
fft_lhrir = fft(l_hrir);    % 对HRIR数据进行fft变换
fft_rhrir = fft(r_hrir);

frame_len = 1024;               % 帧长
overlap = 512;                  % 重叠50%
w = hann(frame_len);            % 汉宁窗函数
s = frame_len - overlap;
m = mod(length(tmp_audio),s);
tmp_audio = [tmp_audio zeros(1,frame_len-m)];   % 为数据处理方便，在原信号上补零
len = length(tmp_audio);
output = zeros(2,len,'double'); % 对输出重新分配空间
for i = 0:len / s -2
    seg = tmp_audio((i*s+1):(i*s+frame_len))';  % 当前处理的帧
    seg = seg.*w;                               % 加窗
    % fft
    fft_tmp = fft(seg);                         
    % HRIR数据与声音信号卷积
    lconv = fft_tmp.*fft_lhrir;                 
    rconv = fft_tmp.*fft_rhrir;
    % ifft
    lifft = ifft(lconv);
    rifft = ifft(rconv);
    % 有overlap的帧合并
    output(1,1+i*s:(i*s+frame_len)) = output(1,1+i*s:(i*s+frame_len))+lifft';
    output(2,1+i*s:(i*s+frame_len)) = output(2,1+i*s:(i*s+frame_len))+rifft';
end

% --- Executes on button press in update_dynamic_button.
function update_dynamic_button_Callback(hObject, eventdata, handles)
global audio;
global output;
% 起点位置
global dy_s_azi;    
global dy_s_elev;
global dy_s_dist;
% 终点位置
global dy_e_azi;
global dy_e_elev;
global dy_e_dist;

% 动态虚拟声音合成
tmp_audio = audio';
frame_len = 1024;               % 帧长
overlap = 512;                  % 重叠50%
w = hann(frame_len);            % 汉宁窗函数
s = frame_len - overlap;
m = mod(length(tmp_audio),s);
tmp_audio = [tmp_audio zeros(1,frame_len-m)];
len = length(tmp_audio); 
n = len / s;
output = zeros(2,len,'double');

% 将运动轨迹分成n个点（n为帧的个数）
azi_list = dy_s_azi:(dy_e_azi-dy_s_azi)/(n-1):dy_e_azi;
elev_list = dy_s_elev:(dy_e_elev-dy_s_elev)/(n-1):dy_e_elev;
dist_list = dy_s_dist:(dy_e_dist-dy_s_dist)/(n-1):dy_e_dist;
loc_mat = [azi_list;elev_list;dist_list];

for i = 0:len/s-2
    % 计算与给定位置最近的两个HRTF数据库测量点位置以及距离
    [first_loc,second_loc,dist_arr] = find_closest(loc_mat(1,i+1),loc_mat(2,i+1),loc_mat(3,i+1));
    % 权重是距离的反比
    w1 = 1/dist_arr(1);
    w2 = 1/dist_arr(2);
    first_lf = sprintf('PKU-IOA HRTF database\\dist%d\\elev%d\\azi%d_elev%d_dist%d.dat',first_loc(3),first_loc(2),first_loc(1),first_loc(2),first_loc(3));
    first_rf = sprintf('PKU-IOA HRTF database\\dist%d\\elev%d\\azi%d_elev%d_dist%d.dat',first_loc(3),first_loc(2),360-first_loc(1),first_loc(2),first_loc(3));
    first_lfid = fopen(first_lf,'r');   first_lhrir = fread(first_lfid,1024,'double');
    first_rfid = fopen(first_rf,'r');   first_rhrir = fread(first_rfid,1024,'double');
    % 若在HRTF数据库中正好有间隔点的位置，不需要读取第二个最近点的数据
    if dist_arr(1) > 0 
        second_lf = sprintf('PKU-IOA HRTF database\\dist%d\\elev%d\\azi%d_elev%d_dist%d.dat',second_loc(3),second_loc(2),second_loc(1),second_loc(2),second_loc(3));
        second_rf = sprintf('PKU-IOA HRTF database\\dist%d\\elev%d\\azi%d_elev%d_dist%d.dat',second_loc(3),second_loc(2),360-second_loc(1),second_loc(2),second_loc(3));
        second_lfid = fopen(second_lf,'r');   second_lhrir = fread(second_lfid,1024,'double');
        second_rfid = fopen(second_rf,'r');   second_rhrir = fread(second_rfid,1024,'double');
        x_l = (w1*first_lhrir + w2*second_lhrir) / (w1 + w2);
        x_r = (w1*first_rhrir + w2*second_rhrir) / (w1 + w2);
    else
        x_l = first_lhrir;
        x_r = first_rhrir;

    end
    fclose('all');
    % 对HRIR数据fft
    fft_lhrir = fft(x_l);
    fft_rhrir = fft(x_r);
    % 当前处理的帧
    tmp = tmp_audio((i*s+1):(i*s+frame_len))';
    tmp = tmp.*w;               % 加窗
    fft_tmp = fft(tmp);         % 对声音信息做fft
    % 卷积
    lconv = fft_tmp.*fft_lhrir;
    rconv = fft_tmp.*fft_rhrir;
    % ifft
    lifft = ifft(lconv);
    rifft = ifft(rconv);
    % 合并
    output(1,1+i*s:(i*s+frame_len)) = output(1,1+i*s:(i*s+frame_len))+lifft';
    output(2,1+i*s:(i*s+frame_len)) = output(2,1+i*s:(i*s+frame_len))+rifft';
    
    set(handles.update_status,'String','1');
end

% --- Executes on button press in start_button.
function start_button_Callback(hObject, eventdata, handles)
global output;
global fs;
global player;
player = audioplayer(output,fs);
set(player,'TimerFcn',{@play_slider,handles});
set(player,'TimerPeriod',0.05);
player.play;
% audiowrite('result.wav',output',fs);
set(handles.update_status,'String','0');

function play_slider(hObject,~,handles)
CurrentSample = get(hObject,'CurrentSample');
len = get(hObject,'TotalSamples');
rate = CurrentSample/len;
set(handles.play_slider,'Value',rate);

% --- Executes on button press in pause_button.
function pause_button_Callback(hObject, eventdata, handles)
global player;
player.pause;

% --- Executes on slider movement.
function play_slider_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function play_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function azi_slider_Callback(hObject, eventdata, handles)
global st_azi;
st_azi = get(hObject,'Value');
set(handles.static_azi,'String',num2str(st_azi));


% --- Executes during object creation, after setting all properties.
function azi_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Value',0);

function static_azi_Callback(hObject, eventdata, handles)
global st_azi;
input = str2double(get(hObject,'String'));
if input <= 360 && input >= 0
    st_azi = input;
    set(handles.azi_slider,'Value',st_azi);
else
    msgbox('invalid value','warning','warn'); %error message window
end    


% --- Executes during object creation, after setting all properties.
function static_azi_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global st_azi;
st_azi = 0;
set(hObject,'string','0');


% --- Executes on slider movement.
function elev_slider_Callback(hObject, eventdata, handles)
global st_elev;
st_elev = get(hObject,'Value')-40;
set(handles.static_elev,'String',num2str(st_elev));


% --- Executes during object creation, after setting all properties.
function elev_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Value',0);

function static_elev_Callback(hObject, eventdata, handles)
global st_elev;
input = str2double(get(hObject,'String'));
if input <= 90 && input >= -40
    st_elev = input;
    set(handles.elev_slider,'Value',st_elev+40);
else
    msgbox('invalid value','warning','warn'); %error message window
end

% --- Executes during object creation, after setting all properties.
function static_elev_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global st_elev;
st_elev = -40;
set(hObject,'string','-40');


% --- Executes on slider movement.
function dist_slider_Callback(hObject, eventdata, handles)
global st_dist;
st_dist = get(hObject,'Value')+20;
set(handles.static_dist,'String',num2str(st_dist));


% --- Executes during object creation, after setting all properties.
function dist_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Value',0);

function static_dist_Callback(hObject, eventdata, handles)
global st_dist;
input = str2double(get(hObject,'String'));
if input <= 160 && input >= 20
    st_dist = input;
    set(handles.dist_slider,'Value',st_dist-20);
else
    msgbox('invalid value','warning','warn'); %error message window
end


% --- Executes during object creation, after setting all properties.
function static_dist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global st_dist;
st_dist = 20;
set(hObject,'string','20');


function start_azi_Callback(hObject, eventdata, handles)
global dy_s_azi;
input = str2double(get(hObject,'String'));
if input <= 360 && input >= 0
    dy_s_azi = input;
else
    msgbox('invalid value','warning','warn'); %error message window
end    


% --- Executes during object creation, after setting all properties.
function start_azi_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global dy_s_azi;
dy_s_azi = 0;
set(hObject,'string','0');


function start_elev_Callback(hObject, eventdata, handles)
global dy_s_elev;
input = str2double(get(hObject,'String'));
if input <= 90 && input >= -40
    dy_s_elev = input;
else
    msgbox('invalid value','warning','warn'); %error message window
end



% --- Executes during object creation, after setting all properties.
function start_elev_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global dy_s_elev;
dy_s_elev = -40;
set(hObject,'string','-40');


function start_dist_Callback(hObject, eventdata, handles)
global dy_s_dist;
input = str2double(get(hObject,'String'));
if input <= 160 && input >= 20
    dy_s_dist = input;
else
    msgbox('invalid value','warning','warn'); %error message window
end


% --- Executes during object creation, after setting all properties.
function start_dist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global dy_s_dist;
dy_s_dist = 20;
set(hObject,'string','20');


function end_azi_Callback(hObject, eventdata, handles)
global dy_e_azi;
input = str2double(get(hObject,'String'));
if input <= 360 && input >= 0
    dy_e_azi = input;
else
    msgbox('invalid value','warning','warn'); %error message window
end  


% --- Executes during object creation, after setting all properties.
function end_azi_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global dy_e_azi;
dy_e_azi = 180;
set(hObject,'string','180');


function end_elev_Callback(hObject, eventdata, handles)
global dy_e_elev;
input = str2double(get(hObject,'String'));
if input <= 90 && input >= -40
    dy_e_elev = input;
else
    msgbox('invalid value','warning','warn'); %error message window
end


% --- Executes during object creation, after setting all properties.
function end_elev_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global dy_e_elev;
dy_e_elev = 50;
set(hObject,'string','50');


function end_dist_Callback(hObject, eventdata, handles)
global dy_e_dist;
input = str2double(get(hObject,'String'));
if input <= 160 && input >= 20
    dy_e_dist = input;
else
    msgbox('invalid value','warning','warn'); %error message window
end


% --- Executes during object creation, after setting all properties.
function end_dist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global dy_e_dist;
dy_e_dist = 140;
set(hObject,'string','140');



function update_status_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function update_status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to update_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string','0');
