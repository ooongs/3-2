function varargout = lab5(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lab5_OpeningFcn, ...
                   'gui_OutputFcn',  @lab5_OutputFcn, ...
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

function lab5_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
init_bg();
global res;
axes(handles.axes1);
imshow(res);
axes(handles.axes2);
imshow(res);
axes(handles.axes3);
imshow(res);

function varargout = lab5_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function imgtxt_Callback(hObject, eventdata, handles)


function imgtxt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_img.
function select_img_Callback(hObject, eventdata, handles)
global img
[file,path] = uigetfile('*.tif');
str = path + "/" + file;
img = imread(str);
set(handles.imgtxt,'String',file);
axes(handles.axes1)
imshow(img)

function param1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function param1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Visible','off')


function param2_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function param2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Visible','off')



function noisetxt_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function noisetxt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in noise_confirm.
function noise_confirm_Callback(hObject, eventdata, handles)
global noise
global img
m = get(handles.noise_menu,'Value');
if m == 1
    noise = imnoise(img,'gaussian');
elseif m == 2
    noise = imnoise(img,'salt & pepper');
else 
    noise = imnoise(img,'speckle');
end
axes(handles.axes1)
imshow(img)
axes(handles.axes2)
imshow(noise)
s = num2str(round(PSNR(img,noise),2));
psnr = "PSNR:"+s;
set(handles.noise_psnr,'String',psnr);

function filtertxt_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function filtertxt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in filter_confirm.
function filter_confirm_Callback(hObject, eventdata, handles)
global noise
global img
global filtered
m = get(handles.filter_menu,'Value');
if m == 1
    filtered = meanFilter(noise);
elseif m == 2
    filtered = medianFilter(noise);
elseif m == 3
    x = str2double(get(handles.param1,'String'));
    filtered = lowpassFilter(noise,x);
else 
    x = str2double(get(handles.param1,'String'));
    y = round(get(handles.param2,'String'));
    filtered = blpfFilter(noise,x,y);
end
axes(handles.axes1)
imshow(img)
axes(handles.axes2)
imshow(noise)
axes(handles.axes3)
imshow(filtered)
s = num2str(round(PSNR(img,filtered),2));
psnr = "PSNR:"+s;
set(handles.enhanced_psnr,'String',psnr);

% --- Executes on selection change in noise_menu.
function noise_menu_Callback(hObject, eventdata, handles)
m = get(hObject,'Value');
if m == 1
    set(handles.noisetxt,'String','Gaussian Noise')
elseif m == 2
    set(handles.noisetxt,'String','Salt & Pepper Noise')
else
    set(handles.noisetxt,'String','Speckle Noise')
end

% --- Executes during object creation, after setting all properties.
function noise_menu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in filter_menu.
function filter_menu_Callback(hObject, eventdata, handles)
m = get(hObject,'Value');

if m == 3           % low pass filter
    set(handles.param1,'Visible','on')
    set(handles.param2,'Visible','off')
    set(handles.param1,'String','70');
    set(handles.filtertxt,'String','Low Pass Filter');
elseif m == 4       % blpf filter
    set(handles.param1,'Visible','on')
    set(handles.param2,'Visible','on')
    set(handles.param1,'String','50');
    set(handles.param2,'String','3');
    set(handles.filtertxt,'String','Butterworth Filter');
else 
    set(handles.param1,'Visible','off')
    set(handles.param2,'Visible','off')
    if m == 1
        set(handles.filtertxt,'String','Mean Filter');
    else
        set(handles.filtertxt,'String','Median Filter');
    end
end


% --- Executes during object creation, after setting all properties.
function filter_menu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function init_bg()
global res;
res = uint8(zeros(500, 500, 3));
for i = 1:500
    for j = 1:500
        res(i,j,1:3)=[255,255,255];
    end
end

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


function psnr = PSNR(img,noise)
[n,m] = size(img);
img1 = double(img);
img2 = double(noise);
MAXI = 255;
MSE = sum(sum((img1-img2).^2))/(m*n);
psnr = 20*log10(MAXI/sqrt(MSE));



function enhanced_psnr_Callback(hObject, eventdata, handles)
% hObject    handle to enhanced_psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enhanced_psnr as text
%        str2double(get(hObject,'String')) returns contents of enhanced_psnr as a double


% --- Executes during object creation, after setting all properties.
function enhanced_psnr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enhanced_psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noise_psnr_Callback(hObject, eventdata, handles)
% hObject    handle to noise_psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_psnr as text
%        str2double(get(hObject,'String')) returns contents of noise_psnr as a double


% --- Executes during object creation, after setting all properties.
function noise_psnr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
