function varargout = Caltrain(varargin)
% CALTRAIN M-file for Caltrain.fig
%      CALTRAIN, by itself, creates a new CALTRAIN or raises the existing
%      singleton*.
%
%      H = CALTRAIN returns the handle to a new CALTRAIN or the handle to
%      the existing singleton*.
%
%      CALTRAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALTRAIN.M with the given input arguments.
%
%      CALTRAIN('Property','Value',...) creates a new CALTRAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Caltrain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Caltrain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Caltrain

% Last Modified by GUIDE v2.5 12-Dec-2011 16:06:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Caltrain_OpeningFcn, ...
                   'gui_OutputFcn',  @Caltrain_OutputFcn, ...
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


% --- Executes just before Caltrain is made visible.
function Caltrain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Caltrain (see VARARGIN)

% Commute information
handles.start_station = 'San Francisco';
handles.stop_station = 'Mountain View';

% leave_window = {'07:00','09:00'};
% return_window = {'16:00','18:00'};

handles.leave_hour = 8;
handles.leave_minute = 0;
handles.return_hour = 17;
handles.return_minute = 0;
handles.leave_delta = 1;
handles.return_delta = 1;
    
% Load in the train data
fid = fopen('CaltrainStations.txt','rt');
stations = {};
n_stations = 0;
while feof(fid) == 0
    stations = [stations; fgetl(fid)];
    n_stations = n_stations + 1;
end
fclose(fid);

handles.stations = stations;

disp('Successfully loaded the Caltrain Stations')

fid = fopen('CaltrianNBSchedule.bin','r');
fseek(fid,0,1); n_bytes = ftell(fid);  fseek(fid,0,-1);
n_stops = (n_bytes/8)/(n_stations+1);
[nb,count] = fread(fid,[n_stops,n_stations+1],'double');
fclose(fid);

handles.nb_sched = nb(:,2:end);
handles.nb_trains = nb(:,1);
clear nb

fid = fopen('CaltrianSBSchedule.bin','r');
fseek(fid,0,1); n_bytes = ftell(fid);  fseek(fid,0,-1);
n_stops = (n_bytes/8)/(n_stations+1);
[sb,count] = fread(fid,[n_stops,n_stations+1],'double');
fclose(fid);

handles.sb_sched = sb(:,2:end);
handles.sb_trains = sb(:,1);
clear sb

disp('Successfully loaded Caltrain Schedule.')
    
% Set the GUI parameters

handles.start_id = strmatch(handles.start_station, handles.stations);
handles.stop_id = strmatch(handles.stop_station, handles.stations);

leave_time = daytime2str((handles.leave_hour + handles.leave_minute/60)/24);
return_time = daytime2str((handles.return_hour + handles.return_minute/60)/24);

set(handles.homestation_popup,'String',handles.stations);
set(handles.workstation_popup,'String',handles.stations);
set(handles.homestation_popup,'Value',handles.start_id);
set(handles.workstation_popup,'Value',handles.stop_id);

set(handles.home_hour_edit,'String',leave_time(1:2));
set(handles.home_minute_edit,'String',leave_time(4:5));
set(handles.work_hour_edit,'String',return_time(1:2));
set(handles.work_minute_edit,'String',return_time(4:5));

set(handles.home_delta_edit,'String',num2str(handles.leave_delta));
set(handles.work_delta_edit,'String',num2str(handles.return_delta));

handles = updateSchedule(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%% Initialize Map Data

% Load in the train data
fid = fopen('CaltrainStations.txt','rt');
stations = {};
n_stations = 0;
while feof(fid) == 0
    stations = [stations; fgetl(fid)];
    n_stations = n_stations + 1;
end
fclose(fid);

handles.map.station_locationstation_location = zeros(n_stations,2);

im = imread('Caltrain Zone Map.jpg');

a = im(55:70,230:247,3);
a(:,1:4) = 0;
a(:,16:end) = 0;
a(1:3,:) = 0;
a(14:end,:) = 0;


temp1 = im(:,1:300,1);

b = imfilter(double(temp1),double(a));


% Find the stations

mask = zeros(size(temp1));
mask(b > 5.2e6) = 1;

% im2 = im .* mask;
im2 = mask';

BW = im2bw(im2);

cc = bwconncomp(BW);

for i = 1:cc.NumObjects
    roi = cc.PixelIdxList{i};
    col = ceil(roi/cc.ImageSize(1,1));
    row = roi - (col-1)*cc.ImageSize(1,1);
    
    % compute the centroid
    cent_x = (col' * ones(length(col),1))/length(col);
    cent_y = (row' * ones(length(row),1))/length(row);
    
    handles.map.station_location(i,:) = [cent_x,cent_y];
    
end

handles.map.im = im;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Choose default command line output for Caltrain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Caltrain wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Caltrain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in update_button.
function update_button_Callback(hObject, eventdata, handles)
% hObject    handle to update_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.status_text,'String','Status: Querying @Caltrain Twitter Feed...')

if 1
    % GET LIVE DATA
%     url_data = urlread('http://search.twitter.com/search.json?q=%40from:caltrain');
    
    % Get tweets in the last 10 days
%     datestr(today-10,29)
    url_data = urlread(['http://search.twitter.com/search.json?q=%40from:caltrain%20since%3A',datestr(now-7,29)]);
    
    url_data = parse_json(url_data);
    assignin('base','url_data',url_data);
else
    % use test data from the workspace
    url_data = evalin('base','url_data');
end

% Parse out the twitter feed data
% n_results = url_data{1}.results_per_page;
n_results = length(url_data{1}.results);
entries = url_data{1}.results;
twitter_data = cell(n_results,4);

for i = 1:n_results
    % note:  time is in GMT, not PST
    [output_time, output_day] = parse_caltrain_time(entries{i}.created_at);
    [output_time, output_day] = gmt_to_pst(output_time, output_day);
    twitter_data{i,1} = output_time;
    twitter_data{i,2} = output_day;
    twitter_data{i,3} = entries{i}.from_user;
    twitter_data{i,4} = entries{i}.text;
end

current_date = datenum(date);

handles.last_update = now;
handles.twitter_data = twitter_data;

listbox_str = cell(n_results,1);

for i = 1:n_results
    listbox_str{i,1} = [datestr(datenum(twitter_data{i,1})),' : ',twitter_data{i,4}];
end

set(handles.listbox1,'String',listbox_str);
set(handles.status_text,'String',['Last updated at: ',datestr(handles.last_update)])

guidata(hObject,handles);



% --- Executes on selection change in homestation_popup.
function homestation_popup_Callback(hObject, eventdata, handles)
% hObject    handle to homestation_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns homestation_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from homestation_popup

handles = guidata(hObject);
handles = updateSchedule(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function homestation_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to homestation_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
handles = guidata(hObject);
handles = updateSchedule(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function work_hour_edit_Callback(hObject, eventdata, handles)
% hObject    handle to work_hour_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of work_hour_edit as text
%        str2double(get(hObject,'String')) returns contents of work_hour_edit as a double
handles = guidata(hObject);
handles = updateSchedule(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function work_hour_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to work_hour_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function work_minute_edit_Callback(hObject, eventdata, handles)
% hObject    handle to work_minute_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of work_minute_edit as text
%        str2double(get(hObject,'String')) returns contents of work_minute_edit as a double
handles = guidata(hObject);
handles = updateSchedule(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function work_minute_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to work_minute_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function work_delta_edit_Callback(hObject, eventdata, handles)
% hObject    handle to work_delta_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of work_delta_edit as text
%        str2double(get(hObject,'String')) returns contents of work_delta_edit as a double
handles = guidata(hObject);
handles = updateSchedule(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function work_delta_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to work_delta_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in workstation_popup.
function workstation_popup_Callback(hObject, eventdata, handles)
% hObject    handle to workstation_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns workstation_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from workstation_popup

handles = guidata(hObject);
handles = updateSchedule(hObject,handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function workstation_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to workstation_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function home_hour_edit_Callback(hObject, eventdata, handles)
% hObject    handle to work_hour_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of work_hour_edit as text
%        str2double(get(hObject,'String')) returns contents of work_hour_edit as a double
handles = guidata(hObject);
handles = updateSchedule(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function home_hour_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to work_hour_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function home_minute_edit_Callback(hObject, eventdata, handles)
% hObject    handle to work_minute_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of work_minute_edit as text
%        str2double(get(hObject,'String')) returns contents of work_minute_edit as a double
handles = guidata(hObject);
handles = updateSchedule(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function home_minute_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to work_minute_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function home_delta_edit_Callback(hObject, eventdata, handles)
% hObject    handle to work_delta_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of work_delta_edit as text
%        str2double(get(hObject,'String')) returns contents of work_delta_edit as a double

handles = guidata(hObject);
handles = updateSchedule(hObject,handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function home_delta_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to work_delta_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in map_button.
function map_button_Callback(hObject, eventdata, handles)
% hObject    handle to map_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.figure1,'Units','Pixels');
fig_pos = get(handles.figure1,'Position');

figure
imshow(handles.map.im);
hold on
% plot(station_location(:,2),station_location(:,1),'kx')
set(gca,'Position',[0 0 1 1])
% xlim = [0 cc.ImageSize(2)];
% ylim = [0 cc.ImageSize(1)];
set(gcf,'Position',[(fig_pos(1) + fig_pos(3) + 25)   fig_pos(2)-50   473   868]);

handles.start_station = handles.stations{get(handles.homestation_popup,'Value')};
handles.stop_station = handles.stations{get(handles.workstation_popup,'Value')};
handles.start_id = length(handles.stations) - strmatch(handles.start_station, handles.stations) + 1;
handles.stop_id = length(handles.stations) - strmatch(handles.stop_station, handles.stations) + 1;

plot(handles.map.station_location(handles.start_id,2),handles.map.station_location(handles.start_id,1),'g.','MarkerSize',30)
plot(handles.map.station_location(handles.stop_id,2),handles.map.station_location(handles.stop_id,1),'r.','MarkerSize',30)

plot(handles.map.station_location(handles.start_id:handles.stop_id,2),handles.map.station_location(handles.start_id:handles.stop_id,1),'y','LineWidth',3)


function handles = updateSchedule(hObject,handles)

% handles.leave_hour = 8;
% handles.leave_minute = 0;
% handles.return_hour = 17;
% handles.return_minute = 0;
% handles.leave_delta = 1;
% handles.return_delta = 1;

handles.leave_hour = str2double(get(handles.home_hour_edit,'String'));
handles.leave_minute = str2double(get(handles.home_minute_edit,'String'));
handles.leave_delta = str2double(get(handles.home_delta_edit,'String'));

handles.return_hour = str2double(get(handles.work_hour_edit,'String'));
handles.return_minute = str2double(get(handles.work_minute_edit,'String'));
handles.return_delta = str2double(get(handles.work_delta_edit,'String'));

leave_window_t(1,1) = (handles.leave_hour - handles.leave_delta + handles.leave_minute/60)/24;
leave_window_t(2,1) = (handles.leave_hour + handles.leave_delta + handles.leave_minute/60)/24;
return_window_t(1,1) = (handles.return_hour - handles.return_delta + handles.return_minute/60)/24;
return_window_t(2,1) = (handles.return_hour + handles.return_delta + handles.return_minute/60)/24;

% Find the to-work trains
% Determine the commute direction

handles.start_station = handles.stations{get(handles.homestation_popup,'Value')};
handles.stop_station = handles.stations{get(handles.workstation_popup,'Value')};
handles.start_id = strmatch(handles.start_station, handles.stations);
handles.stop_id = strmatch(handles.stop_station, handles.stations);

commute_dir = handles.start_id - handles.stop_id;  % if this is positive (first leg is southbound)

%%%%%%%%%%%%%%%%%%%%%%%%  OUTBOUND ROUTE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find all trains that depart the desired location
departing_trains = [];
departing_train_nos = {};
departing_times = {};

if commute_dir > 0
    % look at the southbound trains
    handles.start_id_s = length(handles.stations) - handles.start_id + 1;
    handles.stop_id_s = length(handles.stations) - handles.stop_id + 1;
    for i = 1:size(handles.sb_sched,1)
        if handles.sb_sched(i,handles.start_id_s) > leave_window_t(1,1)
            if handles.sb_sched(i,handles.start_id_s) < leave_window_t(2,1)
                if ~isnan(handles.sb_sched(i,handles.stop_id_s))
                    departing_trains = [departing_trains; handles.sb_trains(i)];
                    [time_str1,mins_out1] = daytime2str(handles.sb_sched(i,handles.start_id_s));
                    [time_str2,mins_out2] = daytime2str(handles.sb_sched(i,handles.stop_id_s));
%                     disp(['   ',num2str(sb_trains(i)),'   |   ',time_str1,'   |   ',time_str2,'   |  ',num2str(mins_out2-mins_out1),' min |'])
                    departing_train_nos = [departing_train_nos; {handles.sb_trains(i)}];
                    departing_times = [departing_times; {time_str1}, {time_str2}, {num2str(mins_out2-mins_out1)}];
                end
            end
        end
    end
    
else
    % look at the northbound trains
    for i = 1:size(handles.nb_sched,1)
        if handles.nb_sched(i,handles.start_id) > leave_window_t(1,1)
            if handles.nb_sched(i,handles.start_id) < leave_window_t(2,1)
                if ~isnan(handles.nb_sched(i,handles.stop_id))
                    departing_trains = [departing_trains; handles.nb_trains(i)];
                    [time_str1,mins_out1] = daytime2str(handles.nb_sched(i,handles.start_id));
                    [time_str2,mins_out2] = daytime2str(handles.nb_sched(i,handles.stop_id));
%                     disp(['   ',num2str(nb_trains(i)),'   |   ',time_str1,'   |   ',time_str2,'   |  ',num2str(mins_out2-mins_out1),' min |'])
                    departing_train_nos = [departing_train_nos; {handles.nb_trains(i)}];
                    departing_times = [departing_times; {time_str1}, {time_str2}, {num2str(mins_out2-mins_out1)}];
                end
            end
        end
    end
end


set(handles.uitable1,'Data',departing_times)
set(handles.uitable1,'RowName',departing_trains)

%%%%%%%%%%%%%%%%%%%%%%%%  HOMEWARD BOUND ROUTE  %%%%%%%%%%%%%%%%%%%%%%%%%%%

arriving_trains = [];
arriving_train_nos = {};
arriving_times = {};

if commute_dir > 0
    % look at the northbound trains
%     handles.start_id_s = length(stations) - handles.start_id + 1;
%     handles.stop_id_s = length(stations) - handles.stop_id + 1;
    for i = 1:size(handles.nb_sched,1)
        if handles.nb_sched(i,handles.stop_id) > return_window_t(1,1)
            if handles.nb_sched(i,handles.stop_id) < return_window_t(2,1)
                if ~isnan(handles.nb_sched(i,handles.start_id))
                    arriving_trains = [arriving_trains; handles.nb_trains(i)];
                    [time_str1,mins_out1] = daytime2str(handles.nb_sched(i,handles.stop_id));
                    [time_str2,mins_out2] = daytime2str(handles.nb_sched(i,handles.start_id));
%                     disp(['   ',num2str(nb_trains(i)),'   |   ',time_str1,'   |   ',time_str2,'   |  ',num2str(mins_out2-mins_out1),' min |'])
                    arriving_train_nos = [arriving_train_nos; {handles.nb_trains(i)}];
                    arriving_times = [arriving_times; {time_str1}, {time_str2}, {num2str(mins_out2-mins_out1)}];

                end
            end
        end
    end
%     disp(['Return home is northbound, found ',num2str(length(departing_trains)),' trains from ',stop_station,' and ',start_station,...
%         ' between ',return_window{1},' and ',return_window{2},'.'])
else
    handles.start_id_s = length(stations) - handles.start_id + 1;
    handles.stop_id_s = length(stations) - handles.stop_id + 1;
    % look at the southbound trains
    for i = 1:size(handles.sb_sched,1)
        if handles.sb_sched(i,handles.stop_id_s) > return_window_t(1,1)
            if handles.sb_sched(i,handles.stop_id_s) < return_window_t(2,1)
                if ~isnan(handles.sb_sched(i,handles.start_id_s))
                    arriving_trains = [arriving_trains; handles.sb_trains(i)];
                    [time_str1,mins_out1] = daytime2str(handles.sb_sched(i,handles.stop_id_s));
                    [time_str2,mins_out2] = daytime2str(handles.sb_sched(i,handles.start_id_s));
%                     disp(['   ',num2str(sb_trains(i)),'   |   ',time_str1,'   |   ',time_str2,'   |  ',num2str(mins_out2-mins_out1),' min |'])
                    arriving_train_nos = [arriving_train_nos; {handles.sb_trains(i)}];
                    arriving_times = [arriving_times; {time_str1}, {time_str2}, {num2str(mins_out2-mins_out1)}];
                end
            end
        end
    end
%     disp(['Initial commute is northbound, found ',num2str(length(departing_trains)),' trains from ',start_station,' and ',stop_station,...
%         ' between ',leave_window{1},' and ',leave_window{2},'.'])
end
% disp('===========================================')

set(handles.uitable2,'Data',arriving_times)
set(handles.uitable2,'RowName',arriving_trains)


function [output_time,output_day] = parse_caltrain_time(input_time)
% Parse the time from the Caltrain/Twitter time stamp

input_time(8) = '-';
input_time(12) = '-';

output_time = datevec(input_time(6:25),0);

output_day = datenum(input_time(6:16),1);

function [output_time, output_day] = gmt_to_pst(input_time, input_day)
% Convert GMT time to PST time

gmt_hour = input_time(4);
pst_hour = gmt_hour - 8;

output_time = input_time;

if pst_hour < 0
    pst_hour = 24 + gmt_hour - 8;
    output_day = input_day - 1;
    temp = datevec(output_day);
    output_time(4) = pst_hour;
    output_time(1:3) = temp(1:3);
else
    output_time(4) = pst_hour;
    output_day = input_day;
end

function [time_str,mins_out] = daytime2str(input_time)
% Convert the time in days to a HH:MM format

hrs = floor(input_time*24);
mins = round((input_time - hrs/24)*(24*60));

hrs_str = num2str(hrs);
mins_str = num2str(mins);

if length(hrs_str) == 1
    hrs_str = ['0',hrs_str];
end

if length(mins_str) == 1
    mins_str = ['0',mins_str];
end

time_str = [hrs_str,':',mins_str];
mins_out = hrs * 60 + mins;

function [output_time] = timestr2day(input_str)

colon_id = strfind(input_str,':');

hrs = str2double(input_str(colon_id + (-2:-1)));
mins = str2double(input_str(colon_id + (1:2)));

output_time = (hrs + mins/60)/24;

if output_time > 1
    output_time = output_time - 1;
end


