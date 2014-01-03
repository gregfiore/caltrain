station_aliases = cell(29,1);

station_aliases{1,1} = {'Gilroy'};
station_aliases{2,1} = {'San Martin','sanmartin'};
station_aliases{3,1} = {'Morgan Hill','morganhill'};
station_aliases{4,1} = {'Blossom Hill','blossomhill'};
station_aliases{5,1} = {'Capitol'};
station_aliases{6,1} = {'Tamien'};
station_aliases{7,1} = {'San Jose','sanjose','SJ','SJD','diridon'};
station_aliases{8,1} = {'College Park','CP','collegepark'};
station_aliases{9,1} = {'Santa Clara','santaclara','scl'};
station_aliases{10,1} = {'Lawrence','law'};
station_aliases{11,1} = {'Sunnyvale','Svl','sv'};
station_aliases{12,1} = {'Mountain View','MV','Mt View','Mtn View','MtView','mtv','mtnview','mountainview'};
station_aliases{13,1} = {'San Antonio','SA','san ant','sanantonio'};
station_aliases{14,1} = {'California Ave','Cal Ave','CalAve','californiaave'};
station_aliases{15,1} = {'Palo Alto','PA','university','paloalto'};
station_aliases{16,1} = {'Menlo Park','MP','Menlo'};
station_aliases{17,1} = {'Redwood City','RC','RWC','redwood'};
station_aliases{18,1} = {'San Carlos','SC','SNC','SCar','SCarlos','sancarlos'};
station_aliases{19,1} = {'Belmont'};
station_aliases{20,1} = {'Hillsdale','HD'};
station_aliases{21,1} = {'Hayward Park','HP','haywardpark','hayyard'};
station_aliases{22,1} = {'San Mateo','SMateo','SM','sanmateo'};
station_aliases{23,1} = {'Burlingame','bvrlingame','bgame','brlngame'};
station_aliases{24,1} = {'Millbrae','MB','Milbrae','millbrea','mil'};
station_aliases{25,1} = {'San Bruno','sanbruno'};
station_aliases{26,1} = {'South San Francisco','So. San Francisco'};
station_aliases{27,1} = {'Bayshore'};
station_aliases{28,1} = {'22nd Street','22nd'};
station_aliases{29,1} = {'San Francisco','SF',' King','4th'};  

critical_incidents{1,1} = {'fatal','killed','suicide'};
critical_incidents{2,1} = {'incident','accident','struck'};
critical_incidents{3,1} = {'indefinitely','cancel','severe','broke', 'mechanical'};
critical_incidents{4,1} = {'restrict','signal'};
critical_incidents{5,1} = {'single','track'};
critical_incidents{5,1} = {'all trains'};

psa_notes = {'standing room','http'};

status_descriptors{1,1} = {'min','mn','minutes'}; 
status_descriptors{2,1} = {'couple','few','several','two'};
status_descriptors{3,1} = {'arr','dep','left','at','@'};
status_descriptors{4,1} = {'delay','late','down'};

if 0 
    filename = 'CT Data.xls';
    % Load EXCEL data
    [num, txt, raw] = xlsread(filename);
end

if 1
    
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
    nb_trains = num2str(nb(:,1));
    clear nb
    
    fid = fopen('CaltrianSBSchedule.bin','r');
    fseek(fid,0,1); n_bytes = ftell(fid);  fseek(fid,0,-1);
    n_stops = (n_bytes/8)/(n_stations+1);
    [sb,count] = fread(fid,[n_stops,n_stations+1],'double');
    fclose(fid);
    
    sb_sched = sb(:,2:end);
    sb_trains = num2str(sb(:,1));
    clear sb
end


temp = cell(length(raw),12);
% 1:  Date
% 2:  Original Tweet
% 3:  Associated Station
% 4:  Station Association Score
% 5:  Train number
% 6:  Direction
% 7:  Train/dir score
% 8:  Critical Incident
% 9:  Incident score
% 10:  Train status
% 11:  Train status score
% 12:  Independent Delay Calculated

for i = 1:length(raw)
    temp{i,1} = raw{i,1};
    temp{i,2} = raw{i,2};
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % Station recognition %
    %%%%%%%%%%%%%%%%%%%%%%%
    
    temp{i,4} = 0;
    found_flag = [0, 0, 0, 0];
    for j = 1:length(station_aliases)
        for k = 1:length(station_aliases{j,1})
            idx = strfind(lower(raw{i,2}),lower(station_aliases{j}{k}));
            if idx
                idx = idx(1);
                % figure out if this really is a station
                % capitalization is good
                if strfind(raw{i,2},upper(station_aliases{j}{k}))
                    found_flag(1) = 5;
                end
                % longer names are more reliable
                if length(station_aliases{j}{k}) > 4
                    found_flag(1) = found_flag(1) + length(station_aliases{j}{k});
                end
                
                % preceding spaces are good
                if idx == 1
                    found_flag(1) = found_flag(1) + 3;
                elseif raw{i,2}(idx-1) == ' ';
                    found_flag(1) = found_flag(1) + 3;
                end
                
                % following spaces, commas or periods are even better
                if strfind(' ,.\;)"&',raw{i,2}(idx+length(station_aliases{j}{k})))
                    found_flag(1) = found_flag(1) + 5;
                end
               
                if found_flag(1) > temp{i,4} && found_flag(1) > 3
%                     disp(raw{i,2})
%                     disp(['Station ',station_aliases{j}{k},' has score ',num2str(found_flag(1))])
                    temp{i,4} = found_flag(1);
                    temp{i,3} = station_aliases{j}{1};
                    
                end
                found_flag(1) = 0;
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    % Train recognition %
    %%%%%%%%%%%%%%%%%%%%%
    
    temp{i,7} = 0;
    % Look at northbound leg first
    for j = 1:length(nb_trains)
        idx = strfind(raw{i,2},nb_trains(j,:));
        if idx
            idx = idx(1);  % use the first one...
            found_flag(2) = found_flag(2) + 5;
        else
            idx = strfind(raw{i,2},nb_trains(j,2:3));
            if idx
                idx = idx(1);
                found_flag(2) = found_flag(2) + 3;
            end
        end
        
        if found_flag(2)
            if idx > 3
                if strcmpi(raw{i,2}(idx-3:idx-2),'nb')
                    found_flag(2) = found_flag(2) + 5;
                elseif strcmpi(raw{i,2}(idx-2:idx-1),'nb')
                    found_flag(2) = found_flag(2) + 5;
                end
            elseif idx > 2
                if strcmpi(raw{i,2}(idx-2:idx-1),'nb')
                    found_flag(2) = found_flag(2) + 5;
                end
            end
        elseif strfind(raw{i,2},'nb')
            found_flag(2) = found_flag(2) + 1;
        elseif strfind(raw{i,2},'NB')
            found_flag(2) = found_flag(2) + 2;
        end
        
        if found_flag(2) > 2 && found_flag(2) > temp{i,7}
            temp{i,6} = 'NB';
            temp{i,5} = str2double(nb_trains(j,:));
            temp{i,7} = found_flag(2);
        end        
        found_flag(2) = 0;
    end
    
    
    % Look at southbound leg
    for j = 1:length(sb_trains)
        idx = strfind(raw{i,2},sb_trains(j,:));
        if idx
            found_flag(2) = found_flag(2) + 5;
        else
            idx = strfind(raw{i,2},nb_trains(j,2:3));
            found_flag(2) = found_flag(2) + 3;
        end
        
        if found_flag
            if idx > 3
                if strcmpi(raw{i,2}(idx-3:idx-2),'sb')
                    found_flag(2) = found_flag(2) + 5;
                elseif strcmpi(raw{i,2}(idx-2:idx-1),'sb')
                    found_flag(2) = found_flag(2) + 5;
                end
            elseif idx > 2
                if strcmpi(raw{i,2}(idx-2:idx-1),'sb')
                    found_flag(2) = found_flag(2) + 5;
                end
            end
        elseif strfind(raw{i,2},'sb')
            found_flag(2) = found_flag(2) + 1;
        elseif strfind(raw{i,2},'SB')
            found_flag(2) = found_flag(2) + 2;
        end
        
        if found_flag(2) > 2 && found_flag(2) > temp{i,7}
            temp{i,6} = 'SB';
            temp{i,5} = str2double(sb_trains(j,:));
            temp{i,7} = found_flag(2);
            found_flag(2) = 0;
        end
        found_flag(2) = 0;
    end
    
    if temp{i,7} <= 3
        temp{i,5} = [];
        temp{i,6} = [];
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    % Critical Incident %
    %%%%%%%%%%%%%%%%%%%%%
    
    temp{i,9} = 0;
    for j = 1:length(critical_incidents)
        for k = 1:length(critical_incidents{j,1})
            idx = strfind(lower(raw{i,2}),lower(critical_incidents{j}{k}));
            if idx
                temp{i,8} = [temp{i,8},critical_incidents{j}{k},','];
                found_flag(3) = found_flag(3) + 1;
            end
        end
    end
    temp{i,9} = found_flag(3);        
    temp{i,8} = temp{i,8}(1:(end-1));        
            
    %%%%%%%%%%%%%%%%%%%%%
    %   Train Status    %
    %%%%%%%%%%%%%%%%%%%%%
    
%     status_descriptors{1,1} = {'min','mn','minutes','hr','hour'};
%     status_descriptors{2,1} = {'arrive','depart','left','at','@'};
%     status_descriptors{3,1} = {'delay','late','down'};
    
    temp{i,11} = 0;
    for k = 1:length(status_descriptors{1,1})
        idx = strfind(lower(raw{i,2}),status_descriptors{1}{k});
        if idx
            found_flag(4) = 1;
            temp{i,10} = 'minutes late';
            break
        end
    end
    
    if found_flag(4)
        for k = 1:length(status_descriptors{2,1})
            idx2 = strfind(lower(raw{i,2}),status_descriptors{2}{k});
            if idx2
                found_flag(4) = found_flag(4) + 1;
                temp{i,10} = [status_descriptors{2}{k},' ',temp{i,10}];
            end
        end
    end
    
    if found_flag(4) == 1
        % look for a number
%         idx = strfind(lower(raw{i,2}),status_descriptors{1}{k});
        delay_amt = [];
        for k = (idx-1):-1:1
            if found_flag(4) == 2
                if isstrnum(raw{i,2}(k))
                    delay_amt = [raw{i,2}(k),delay_amt];
                else
                    break
                end
            elseif found_flag(4) == 1
                if strfind(' ,.\;)"&',raw{i,2}(k))
                    % keep going, this is okay
                elseif isstrnum(raw{i,2}(k))
                    delay_amt = [raw{i,2}(k),delay_amt];
                    found_flag(4) = 2;
                else
                    break
                end
            end
        end
            
        temp{i,10} = [delay_amt,' ',temp{i,10}];
        
    end
    
    if ~found_flag(4)
        idx = strfind(lower(raw{i,2}),'late');

        if idx
            delay_amt = [];
            if strcmp(raw{i,2}(idx-2),'m')
                for k = idx-3:-1:1
                    if isstrnum(raw{i,2}(k))
                        delay_amt = [raw{i,2}(k),delay_amt];
                        found_flag(4) = 2;
                    else
                        break
                    end
                end
            end
            temp{i,10} = [delay_amt,' minutes late'];
        end
        
        
    end
    
    temp{i,11} = found_flag(4);
    if found_flag(4) <= 1
        temp{i,10} = [];
    else
        % try to figure out the delay separately
        if ~isempty(temp{i,3}) && ~isempty(temp{i,5})
            current_station = temp{i,3};
            current_train = num2str(temp{i,5});
            if strcmp(temp{i,6},'NB')
                            station_id = strmatch(current_station,stations);

                for k = 1:length(nb_trains)
                    if strcmp(current_train,nb_trains(k,1:3))
                        expected_time = nb_sched(k,station_id);
                        break
                    end
                end
            else
                station_id = length(stations) - strmatch(current_station,stations)+1;

                for k = 1:length(sb_trains)
                    if strcmp(current_train,sb_trains(k,1:3))
                        expected_time = sb_sched(k,station_id);
                        break
                    end
                end
            end
            
            for k = length(raw{i,2}):-1:1
                if strcmp(raw{i,2}(k),':')
                    c_id = k;
                elseif strcmp(raw{i,2}(k),'T')
                    t_id = k;
                    break
                end
            end
            hr_stamp = str2double(raw{i,2}(t_id+1:c_id-1));
            min_stamp = str2double(raw{i,2}(c_id+1:end));
            stamp_time = hr_stamp/24 + min_stamp/24/60;
            
            diff_time = stamp_time - expected_time;
            [time_str,mins_delay] = daytime2str(diff_time);
            
            computed_delay = mins_delay;
            
            temp{i,12} = computed_delay;
            
            
        end
        
        % find the time the post was made
        
    end
    
end

bad_idx = [];

for i = 1:length(temp)
    if isempty(temp{i,3}) && isempty(temp{i,5}) && isempty(temp{i,6}) && isempty(temp{i,8})
        bad_idx = [bad_idx; i];
    end
end

temp2 = temp(bad_idx,:);

