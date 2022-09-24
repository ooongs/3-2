function varargout = lab4(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lab4_OpeningFcn, ...
                   'gui_OutputFcn',  @lab4_OutputFcn, ...
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

function lab4_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for lab4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.param1_text,'Visible','off')
set(handles.param2_text,'Visible','off')
global res;
init_bg()
imshow(res);


function varargout = lab4_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function menu_Callback(hObject, eventdata, handles)

m = get(hObject,'Value');

if m == 2         % 平移
    set(handles.param1_text,'Visible','on')
    set(handles.param2_text,'Visible','on')
    set(handles.param1_text,'String','0');
    set(handles.param2_text,'String','0');
elseif m == 3     % 尺度
    set(handles.param1_text,'Visible','on')
    set(handles.param2_text,'Visible','on')
    set(handles.param1_text,'String','1');
    set(handles.param2_text,'String','1');    
elseif m == 5     % 错切
    set(handles.param1_text,'Visible','on')
    set(handles.param2_text,'Visible','on')
    set(handles.param1_text,'String','1');
    set(handles.param2_text,'String','1');    
elseif m == 4     % 旋转
    set(handles.param1_text,'Visible','on')
    set(handles.param2_text,'Visible','off')
    set(handles.param1_text,'String','0');
else
    set(handles.param1_text,'Visible','off')
    set(handles.param2_text,'Visible','off')
end

global img;
if ~isempty(img)
    init_res()
end

function menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function param1_text_Callback(hObject, eventdata, handles)

function param1_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function param2_text_Callback(hObject, eventdata, handles)


function param2_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function applyButton_Callback(hObject, eventdata, handles)
global res;
global angle;
global shx;
global shy;
m = get(handles.menu,'Value');
x = str2double(get(handles.param1_text,'String'));
y = str2double(get(handles.param2_text,'String'));
init_bg()
if m == 2
    x = round(x);
    y = round(y);
    move_img(x,y)
elseif m == 3
    times_img(x,y)
elseif m == 4
    angle = angle + x;
    rotate_img(angle);
elseif m == 5
    shx = x * (1+shx);
    shy = y * (1+shy);
    sh_img(shx,shy);
elseif m == 6
    effect("manhua");
elseif m == 7
    effect("bingdong");
elseif m == 8
    effect("rongyan");
end
imshow((res))

function file_text_Callback(hObject, eventdata, handles)

function file_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function browseButton_Callback(hObject, eventdata, handles)
global img;
global R;
global C;
global ori_img;
global ori_R;
global ori_C;

[file,path] = uigetfile('*.jpg');
str = path + "/" + file;
img = imread(str);
[R, C,~] = size(img);
ori_img = img;
ori_R = R;
ori_C = C;


init_res();
set(handles.file_text,'String',file);


function init_res()
global img;
global R;
global C;
global res;
global p;
global q;
global ori_R;
global ori_C;
global ori_img;
global angle;
global shx;
global shy;
R = ori_R;
C = ori_C;
p = 250-round(R/2);
q = 250-round(C/2);
img = ori_img;
angle = 0;
shx = 1;
shy = 1;
init_bg();
move_img(0,0);
imshow((res));

function init_bg()
global res;
res = uint8(zeros(500, 500, 3));
for i = 1:500
    for j = 1:500
        res(i,j,1:3)=[255,255,255];
    end
end

function move_img(x,y)
global res;
global img;
global R;
global C;
global p;
global q;
p = p+x; % 平移量X
q = q+y; % 平移量Y
tras = [1 0 p; 0 1 q; 0 0 1]; % 平移的变换矩阵 
for i = 1 : R
    for j = 1 : C
        temp = [i; j; 1];
        temp = tras * temp; % 矩阵乘法
        a = temp(1, 1);
        b = temp(2, 1);
        % 变换后的位置判断是否越界
        if (a <= 500) && (b <= 500) && (a >= 1) && (b >= 1)
            res(a,b,:) = img(i,j,:);
        end
        
    end
end

function times_img(sx,sy)
global p;
global q;
global img;
global R;
global C;
global res;

tras = [1/sx 0 0; 0 1/sy 0; 0 0 1];
r = round(sx * R);
c = round(sy * C);
tmp = zeros(r,c,3);
p = round(p-(R*(sx-1))/2);
q = round(q-(C*(sy-1))/2);
for i = 1 : r
    for j = 1 : c
        temp = [i; j; 1];
        temp = tras * temp; % 矩阵乘法
        x = uint16(temp(1, 1));
        y = uint16(temp(2, 1));
        a = p+i;
        b = q+j;
        % 变换后的位置判断是否越界
        if (x <= R) && (y <= C) && (x >= 1) && (y >= 1)
            tmp(i,j,:) = img(x,y,:);
            if (a <= 500) && (b <= 500) && (a >= 1) && (b >= 1)
                res(a,b,:) = img(x,y,:);
            end
        else
            tmp(i,j,:) = [255, 255, 255];
            if (a <= 500) && (b <= 500) && (a >= 1) && (b >= 1)
                res(a,b,:) = [255, 255, 255];
            end
        end
    end
end
img = tmp;
R = r;
C = c;


function rotate_img(d)
global res;
global img;
global ori_img;
global ori_R;
global ori_C;
global R;
global C;
global p;
global q;
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
        if (x <= ori_R) && (y <= ori_C) && (x >= 1) && (y >= 1)
%             tmp(i-i1+1,j-j1+1,:) = img(x,y,:);
            if (p+i <= 500) && (q+j <= 500) && (p+i >= 1) && (q+j >= 1)
                res(p+i,q+j,:) = ori_img(x,y,:); 
            end
        else
%             tmp(i-i1+1,j-j1+1,:) = [256,256,256];
            if (p+i <= 500) && (q+j <= 500) && (p+i >= 1) && (q+j >= 1)
                res(p+i,q+j,:) = [256,256,256];
            end
        end
    end
end
img = tmp;
R = a;
C = b;


function sh_img(shx,shy)
global R;
global C;
global res;
global img;
global p;
global q;
sh = [1 shy 0; shx 1 0; 0 0 1]';
for i = -round(R + shx*C) : 1 : 2*R + shx * C
    for j = -round(C + shy * R) : 1 : 2*C + shy * R - 20
        temp = [i; j; 1];
        temp = sh * temp; % 矩阵乘法
        x = uint16(temp(1, 1));
        y = uint16(temp(2, 1));
        % 变换后的位置判断是否越界
        if (x <= R) && (y <= C) && (x >= 1) && (y >= 1)
            if (p+i <= 500) && (q+j <= 500) && (p+i >= 1) && (q+j >= 1)
                res(p+i, q+j,:) = img(x, y,:);
            end
        end
    end
end

function effect(type)
global img;
global res;
global R;
global C;
global p;
global q;
for i = 1 : R
    for j = 1 : C
        r = double(img(i,j,1));
        g = double(img(i,j,2));
        b = double(img(i,j,3));
        if type == "manhua"
            r_ = uint8(abs(g-b+g+r)*r/256);
            g_ = uint8(abs(b-g+b+r)*r/256);
            b_ = uint8(abs(b-g+b+r)*g/256);
        elseif type == "bingdong"
            r_ = uint8(abs(r-g-b));
            g_ = uint8(abs(g-b-r));
            b_ = uint8(abs(b-r-g));
        elseif type == "rongyan"
            r_ = uint8(r*128/(g+b+1));
            g_ = uint8(g*128/(b+r+1));
            b_ = uint8(b*128/(r+g+1));
        end
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
        img(i,j,:) = [r_ g_ b_];
        res(p+i,q+j,:) = [r_ g_ b_];
    end
end
