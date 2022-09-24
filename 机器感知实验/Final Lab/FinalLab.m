function varargout = FinalLab(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FinalLab_OpeningFcn, ...
                   'gui_OutputFcn',  @FinalLab_OutputFcn, ...
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


% --- Executes just before FinalLab is made visible.
function FinalLab_OpeningFcn(hObject, eventdata, handles, varargin)
global cam;
global init_img;
set(hObject,'toolbar','figure'); 
cam = webcam(1);
warning off;
init_img = uint8(cam.snapshot);
init_img = flip(init_img,2);
axes(handles.cam_axes);
imshow(init_img);

axes(handles.train_axes);
imshow(uint8([255 255 255]));

axes(handles.skin_axes);
imshow(uint8([255 255 255]));

axes(handles.move_axes);
imshow(uint8([255 255 255]));

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = FinalLab_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
clear;

% --- Executes on selection change in mode_menu.
function mode_menu_Callback(hObject, eventdata, handles)
global kmeans;
global mode;
kmeans = 0;
mode_val = get(handles.mode_menu,'Value');
if mode_val == 1
    kmeans = 1;
    mode = 'Proposed';%'K-means';
% elseif mode_val == 2
%     kmeans = 1;
%     mode = 'CbCr';
elseif mode_val == 2
    mode = 'Proposed';
elseif mode_val == 3
    mode = 'CbCr';
elseif mode_val == 4
    mode = 'HS';
elseif mode_val == 5
    mode = 'HS-CbCr';
elseif mode_val == 6
    mode = 'NormRGB';
else
    kmeans = 1;
    mode = 'Proposed';
end
if kmeans == 1
    set(handles.train_button,'visible','on');
    set(handles.apply_button,'visible','on');
    set(handles.skin_button,'visible','on');
    set(handles.skinSeg_button,'visible','on');
    set(handles.foreGround_button,'visible','on');
    set(handles.backGround_button,'visible','on');
else
    set(handles.train_button,'visible','off');
    set(handles.apply_button,'visible','off');
    set(handles.skinSeg_button,'visible','off');
    set(handles.skin_button,'visible','off');
    set(handles.foreGround_button,'visible','off');
    set(handles.backGround_button,'visible','off');
end

% --- Executes during object creation, after setting all properties.
function mode_menu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global mode
global kmeans

kmeans = 1;
mode = 'Proposed';



% --- Executes on button press in train_button.
function train_button_Callback(hObject, eventdata, handles)
global init_img;
global mode;
global n;
global m;
global C;
global idx;
global cam;
set(handles.text2,'String','Clustered Image')
init_img = cam.snapshot;
init_img = flip(init_img,2);
imshow(init_img, 'Parent', handles.cam_axes);
[idx,C] = trainSkin(init_img,mode);
[n,m,~] = size(init_img);
res = uint8(zeros(n,m));
i = 1;
for x = 1:n
    for y = 1:m
        if idx(i) == 3
            res(x,y,:) = 255;
        elseif idx(i) == 2
            res(x,y,:) = 60;
        else
            res(x,y,:) = 0;
        end
        i = i + 1;
    end
end
res = medfilt2(res);
axes(handles.train_axes)
imshow(res)


% --- Executes on button press in apply_button.
function apply_button_Callback(hObject, eventdata, handles)
global idx;
global n;
global m;
global skin;
global bg;
global fg;
global train_mask;
val = get(handles.skin_button,'SelectedObject');
skin_val = get(val,'string');
val = get(handles.foreGround_button,'SelectedObject');
fg_val = get(val,'string');
val = get(handles.skin_button,'SelectedObject');
bg_val = get(val,'string');
if skin_val == "Black"
    skin = 1;
elseif skin_val == "Grey"
    skin = 2;
else
    skin = 3;
end
if fg_val == "Black"
    fg = 1;
elseif fg_val == "Grey"
    fg = 2;
else
    fg = 3;
end
if bg_val == "Black"
    bg = 1;
elseif bg_val == "Grey"
    bg = 2;
else
    bg = 3;
end
train_mask = cluster2mask(idx,n,m,skin,bg,fg);
train_mask = medfilt2(train_mask);
axes(handles.train_axes)
imshow(train_mask)


% --- Executes on button press in pause_button.
function pause_button_Callback(hObject, eventdata, handles)
handles.stop_now = 1;
guidata(hObject, handles); % Update handl



% --- Executes on button press in start_button.
function start_button_Callback(hObject, eventdata, handles)
global cam;
global mode;
global kmeans;
global C;
global n;
global m;
global skin;
global bg;
global fg;
global init_img;
handles.stop_now = 0;
guidata(hObject,handles);
set(handles.text2,'String','Hand Region')

% filt = 1/9*ones(3);
se = strel('square',3);
se90 = strel('line',10,90);
% se45 = strel('line',8,45);
se0 = strel('line',3,0);
seD = strel('diamond',1);

% Get Previous Frame
img = uint8(cam.snapshot);
img = flip(img,2);
prev_img = imbilatfilt(img);
% prev_img = imfilter(img,filt);

% Initialize Centroid of Hand (Center of Image)
[n,m,~] = size(img);
moveCC_x = n/2;
moveCC_y = m/2;

while ~(handles.stop_now)
    % Get Current Frame
    img = uint8(cam.snapshot);
    img = flip(img,2);
    filt_img = imbilatfilt(img);
    
    % Skin Detection
    if kmeans == 1
        [idx] = testSkin(filt_img,C,mode);
        final_skin = cluster2mask(idx,n,m,skin,bg,fg);
    else
        final_skin = skinSeg(filt_img,mode);
    end
    
    % Motion Detection
    mask_md = motionDetection(filt_img,prev_img);
    imshow(mask_md, 'Parent', handles.move_axes);
    
    % Centroid of Motion Detection BW
    stat = regionprops(mask_md, 'centroid');
    moveC = cat(1,stat.Centroid);
    if ~isempty(moveC)
        moveC_x = moveC(:,1);
        moveC_y = moveC(:,2);
        % Points convert to Polygon
        pgon = polyshape(moveC_x,moveC_y);
        % Calculate Centroid of Polygon
        [tmpx,tmpy] = centroid(pgon);
        if ~(isnan(tmpx)||isnan(tmpy))
            moveCC_x = tmpx;
            moveCC_y = tmpy;
        end
        hold(handles.move_axes,'on');
        plot(pgon,'Parent', handles.move_axes);
        plot(moveCC_x,moveCC_y,'y*','Parent', handles.move_axes)
        plot(moveC_x,moveC_y,'r*','Parent', handles.move_axes)
        hold(handles.move_axes,'off');
   end  
   
    % Binarize
    bw = final_skin > 100;
    
    % Morphological Image Processing
    bw = bwareaopen(bw,200);
    bw = imopen(bw,se);
    bw = imclose(bw,se);
    bw = imdilate(bw,[se90 se0]);
%     bw = imdilate(bw,se45);
    bw = imfill(bw,'holes');
    skin_mask = imerode(bw,seD);
    
    % Select Biggest Three Blob
    skin_mask = bwareaopen(bwareafilt(skin_mask,3),5000);
    
    % Select Hand Region
    labeledImage = bwlabel(skin_mask);
    stats = regionprops(labeledImage, 'Centroid','BoundingBox');
    if ~isempty(stats)
        % Calculate Distance 
        skinC = vertcat(stats.Centroid);
        skinC_x = skinC(:, 1);
        skinC_y = skinC(:, 2);
        distances = sqrt((moveCC_x - skinC_x) .^ 2 + (moveCC_y - skinC_y) .^ 2);
        
        % Find Nearest
        [~, idx] = min(distances);
        hand_region = ismember(labeledImage, idx);
        
        % Draw ROI
        handRegion = stats(idx).BoundingBox;
        final = insertShape(img,'Rectangle',[handRegion(1),handRegion(2),handRegion(3),handRegion(4)],'LineWidth',2,'Color','red');
        imshow(final,'Parent', handles.cam_axes);
        imshow(hand_region, 'Parent', handles.train_axes);
    else
        imshow(img, 'Parent', handles.cam_axes);
        imshow(skin_mask, 'Parent', handles.train_axes);
    end
    imshow(final_skin, 'Parent', handles.skin_axes);
    drawnow;
    
    % Update Data
    handles = guidata(hObject);
    
    % Update Previous Frame
    prev_img = filt_img;
    
end
init_img = img;
moveCC_x
moveCC_y


% --- Executes on button press in capture_button.
function capture_button_Callback(hObject, eventdata, handles)
global init_img;
global cam;
% init_img = cam.snapshot;
% init_img = flip(init_img,2);
imshow(init_img, 'Parent', handles.cam_axes);
t = datetime('now');
tstr = strcat(datestr(t),'.jpg');
tstr = strrep(tstr,':',';')
imwrite(init_img,tstr);


% --- Executes on button press in skinSeg_button.
function skinSeg_button_Callback(hObject, eventdata, handles)
global init_img;
global train_mask;
img = init_img;
figure;
subplot(3,3,1); imshow(img); title("Original")
m = ["NormRGB","HS","CbCr","HS-CbCr","Proposed"];
for i=2:6
    subplot(3,3,i)
    skinMask = skinSeg(img,m(i-1));
    mask = skinMask >= 1;
    imshow(mask)
    title(m(i-1))
end
subplot(337)
imshow(train_mask);
t = "Histogram + K-means";
title(t)
subplot(338); 
bw = train_mask > 200;
imshow(bw); 
title("Binarized Image");
subplot(339)
se = strel('square',3);
se90 = strel('line',10,90);
se0 = strel('line',3,0);
seD = strel('diamond',1);
bw = bwareaopen(bw,200);
bw = imopen(bw,se);
bw = imclose(bw,se);
bw = imdilate(bw,[se90 se0]);
bw = imfill(bw,'holes');
bw = imerode(bw,seD);

imshow(bw);
title("Morphological Image")
