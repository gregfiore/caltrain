function [] = monitor_caltrain_twitter()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                         ROUTE PROCESSING                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Commute information
start_station = 'San Francisco';
stop_station = 'Mountain View';

% stop_station = 'San Francisco';
% start_station = 'Mountain View';

leave_window = {'07:00','09:00'};
return_window = {'16:00','18:00'};

leave_window_t(1,1) = timestr2day(leave_window{1,1});
leave_window_t(2,1) = timestr2day(leave_window{1,2});

return_window_t(1,1) = timestr2day(return_window{1,1});
return_window_t(2,1) = timestr2day(return_window{1,2});

if 0 
    filename = 'Caltrain.xlsx';
    % Load EXCEL data
    [nb.num, nb.txt, nb.raw] = xlsread(filename,'Northbound','A1:AD44');
    [sb.num, sb.txt, sb.raw] = xlsread(filename,'Southbound','A1:AD44');

    % Stations (in North-bound order)
    fid = fopen('CaltrainStations.txt','wt');
    stations = cell(size(nb.raw,2)-1,1);
    
    for i = 2:size(nb.raw,2)
        stations{i-1} = nb.raw{1,i};
        fprintf(fid,'%s\n',stations{i-1});
    end
    
    fclose(fid);
    disp('Successfull wrote the station names to file: CaltrainStations.txt')
    
    % Write a matrix of schedule
    fid = fopen('CaltrianNBSchedule.bin','w');
    nb_trains = nb.num(1:end,:);
    fwrite(fid,nb_trains,'double');
    fclose(fid);
    
    fid = fopen('CaltrianSBSchedule.bin','w');
    sb_trains = sb.num(1:end,:);
    fwrite(fid,sb_trains,'double');
    fclose(fid);
    
    disp('Successfull wrote the train schedules to file: CaltrainSchedule.bin')
    
else
    
    % Load in the train data
    fid = fopen('CaltrainStations.txt','rt');
    stations = {};
    n_stations = 0;
    while feof(fid) == 0
        stations = [stations; fgetl(fid)];
        n_stations = n_stations + 1;
    end
    fclose(fid);
    
    disp('Successfully loaded the Caltrain Stations')
    
    fid = fopen('CaltrianNBSchedule.bin','r');
    fseek(fid,0,1); n_bytes = ftell(fid);  fseek(fid,0,-1);
    n_stops = (n_bytes/8)/(n_stations+1);
    [nb,count] = fread(fid,[n_stops,n_stations+1],'double');
    fclose(fid);

    nb_sched = nb(:,2:end);
    nb_trains = nb(:,1);
    clear nb
    
    fid = fopen('CaltrianSBSchedule.bin','r');
    fseek(fid,0,1); n_bytes = ftell(fid);  fseek(fid,0,-1);
    n_stops = (n_bytes/8)/(n_stations+1);
    [sb,count] = fread(fid,[n_stops,n_stations+1],'double');
    fclose(fid);
    
    sb_sched = sb(:,2:end);
    sb_trains = sb(:,1);
    clear sb
    
    disp('Successfully loaded Caltrain Schedule.')
    
end

% Find the to-work trains
% Determine the commute direction
start_id = strmatch(start_station, stations);
stop_id = strmatch(stop_station, stations);
commute_dir = start_id - stop_id;  % if this is positive (first leg is southbound)

%%%%%%%%%%%%%%%%%%%%%%%%  OUTBOUND ROUTE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find all trains that depart the desired location
departing_trains = [];
disp(' ')
disp(' ')
disp(['Work-Bound Commute: ',start_station,' -> ',stop_station]);
disp('===========================================')
disp('Train No.| Departs   |  Arrives  | Elapsed |')
disp('===========================================')

if commute_dir > 0
    % look at the southbound trains
    start_id_s = length(stations) - start_id + 1;
    stop_id_s = length(stations) - stop_id + 1;
    for i = 1:size(sb_sched,1)
        if sb_sched(i,start_id_s) > leave_window_t(1,1)
            if sb_sched(i,start_id_s) < leave_window_t(2,1)
                if ~isnan(sb_sched(i,stop_id_s))
                    departing_trains = [departing_trains; sb_trains(i)];
                    [time_str1,mins_out1] = daytime2str(sb_sched(i,start_id_s));
                    [time_str2,mins_out2] = daytime2str(sb_sched(i,stop_id_s));
                    disp(['   ',num2str(sb_trains(i)),'   |   ',time_str1,'   |   ',time_str2,'   |  ',num2str(mins_out2-mins_out1),' min |'])
                end
            end
        end
    end
%     disp(['Initial commute is southbound, found ',num2str(length(departing_trains)),' trains from ',start_station,' and ',stop_station,...
%         ' between ',leave_window{1},' and ',leave_window{2},'.'])
else
    % look at the northbound trains
    for i = 1:size(nb_sched,1)
        if nb_sched(i,start_id) > leave_window_t(1,1)
            if nb_sched(i,start_id) < leave_window_t(2,1)
                if ~isnan(nb_sched(i,stop_id))
                    departing_trains = [departing_trains; nb_trains(i)];
                    [time_str1,mins_out1] = daytime2str(nb_sched(i,start_id));
                    [time_str2,mins_out2] = daytime2str(nb_sched(i,stop_id));
                    disp(['   ',num2str(nb_trains(i)),'   |   ',time_str1,'   |   ',time_str2,'   |  ',num2str(mins_out2-mins_out1),' min |'])
                end
            end
        end
    end
%     disp(['Initial commute is northbound, found ',num2str(length(departing_trains)),' trains from ',start_station,' and ',stop_station,...
%         ' between ',leave_window{1},' and ',leave_window{2},'.'])
end
disp('===========================================')

%%%%%%%%%%%%%%%%%%%%%%%%  HOMEWARD BOUND ROUTE  %%%%%%%%%%%%%%%%%%%%%%%%%%%

arriving_trains = [];
disp(' ')
disp(' ')
disp(['Home-Bound Commute: ',stop_station,' -> ',start_station]);
disp('===========================================')
disp('Train No.| Departs   |  Arrives  | Elapsed |')
disp('===========================================')

if commute_dir > 0
    % look at the northbound trains
%     start_id_s = length(stations) - start_id + 1;
%     stop_id_s = length(stations) - stop_id + 1;
    for i = 1:size(nb_sched,1)
        if nb_sched(i,stop_id) > return_window_t(1,1)
            if nb_sched(i,stop_id) < return_window_t(2,1)
                if ~isnan(nb_sched(i,start_id))
                    arriving_trains = [arriving_trains; nb_trains(i)];
                    [time_str1,mins_out1] = daytime2str(nb_sched(i,stop_id));
                    [time_str2,mins_out2] = daytime2str(nb_sched(i,start_id));
                    disp(['   ',num2str(nb_trains(i)),'   |   ',time_str1,'   |   ',time_str2,'   |  ',num2str(mins_out2-mins_out1),' min |'])
                end
            end
        end
    end
%     disp(['Return home is northbound, found ',num2str(length(departing_trains)),' trains from ',stop_station,' and ',start_station,...
%         ' between ',return_window{1},' and ',return_window{2},'.'])
else
    start_id_s = length(stations) - start_id + 1;
    stop_id_s = length(stations) - stop_id + 1;
    % look at the southbound trains
    for i = 1:size(sb_sched,1)
        if sb_sched(i,stop_id_s) > return_window_t(1,1)
            if sb_sched(i,stop_id_s) < return_window_t(2,1)
                if ~isnan(sb_sched(i,start_id_s))
                    arriving_trains = [arriving_trains; sb_trains(i)];
                    [time_str1,mins_out1] = daytime2str(sb_sched(i,stop_id_s));
                    [time_str2,mins_out2] = daytime2str(sb_sched(i,start_id_s));
                    disp(['   ',num2str(sb_trains(i)),'   |   ',time_str1,'   |   ',time_str2,'   |  ',num2str(mins_out2-mins_out1),' min |'])
                end
            end
        end
    end
%     disp(['Initial commute is northbound, found ',num2str(length(departing_trains)),' trains from ',start_station,' and ',stop_station,...
%         ' between ',leave_window{1},' and ',leave_window{2},'.'])
end
disp('===========================================')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                       TRAIN STATUS PROCESSING                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if 0
    % GET LIVE DATA
    url_data = urlread('http://search.twitter.com/search.json?q=%40from:caltrain');
    
    % Get tweets in the last 10 days
%     datestr(today-10,29)
%     url_data = urlread(['http://search.twitter.com/search.json?q=%40from:caltrain%20since%3A',datestr(today-10,29)]);
    
    url_data = parse_json(url_data);
    assignin('base','url_data',url_data);
else
    % use test data from the workspace
    url_data = evalin('base','url_data');
end

% Parse out the twitter feed data
n_results = url_data{1}.results_per_page;
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

% current_date = datenum(date);
% 
% % find the invalid dates (not today)
% valid_ids = [];
% 
% for i = 1:n_results
%     if twitter_data{i,2} == current_date
%         valid_ids = [valid_ids; i];
%     end
% end
% 
% twitter_data = twitter_data(valid_ids,:);


a =1;




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

function [validity, direction, train_no, delay] = process_tweet(tweet)

dir_id = strfind(lower(tweet),'nb');
if isempty(dir_id)
    dir_id = strfind(lower(tweet),'sb');
    if ~isempty(dir_id)
        direction = 'Southbound';
    end
else
    direction = 'Northbound';    
end

if ~isempty(dir_id)
    train_no = str2double(tweet(dir_id + (2:4)));
end

function station_aliases = get_station_aliases()

station_aliases = cell(29,1);

station_aliases{1,1} = {'Gilroy'};
station_aliases{2,1} = {'San Martin'};
station_aliases{3,1} = {'Morgan Hill'};
station_aliases{4,1} = {'Blossom Hill'};
station_aliases{5,1} = {'Capitol'};
station_aliases{6,1} = {'Tamien'};
station_aliases{7,1} = {'San Jose','SJ','SJD'};
station_aliases{8,1} = {'College Park','CP'};
station_aliases{9,1} = {'Santa Clara'};
station_aliases{10,1} = {'Lawrence'};
station_aliases{11,1} = {'Sunnyvale','Svl'};
station_aliases{12,1} = {'Mountain View','MV','Mt View','Mtn View','MtView'};
station_aliases{13,1} = {'San Antonio','SA'};
station_aliases{14,1} = {'California Ave','CA','Cal Ave','CalAve'};
station_aliases{15,1} = {'Palo Alto','PA'};
station_aliases{16,1} = {'Menlo Park''MP','Menlo'};
station_aliases{17,1} = {'Redwood City','RC','RWC'};
station_aliases{18,1} = {'San Carlos','SC','SNC','SCar'};
station_aliases{19,1} = {'Belmont'};
station_aliases{20,1} = {'Hillsdale','HP'};
station_aliases{21,1} = {'Hayward Park'};
station_aliases{22,1} = {'San Mateo'};
station_aliases{23,1} = {'Burlingame'};
station_aliases{24,1} = {'Millbrae','MB'};
station_aliases{25,1} = {'San Bruno','SB'};
station_aliases{26,1} = {'So. San Francisco'};
station_aliases{27,1} = {'Bayshore'};
station_aliases{28,1} = {'22nd Street','22nd'};
station_aliases{29,1} = {'San Francisco','SF','King','4th'};  

    
