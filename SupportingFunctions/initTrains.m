function [NBtrains, SBtrains] = initTrains()

    global Stations

    n_stations = length(Stations);  % Stations is a global variable

    [nb_trains, nb_sched] = get_trains('NB',n_stations);
    [sb_trains, sb_sched] = get_trains('SB',n_stations);
    
    for i = 1:size(nb_trains,1)
        NBtrains(i,1) = Train('NB',nb_trains(i,:));
        NBtrains(i,1) = get_stops(NBtrains(i,1), nb_sched(i,:), Stations);
    end
    
    for i = 1:size(sb_trains,1)
        SBtrains(i,1) = Train('SB',sb_trains(i,:));
        SBtrains(i,1) = get_stops(SBtrains(i,1), sb_sched(i,:), Stations);
    end
    
end

function [out_trains, out_sched] = get_trains(direction, n_stations)

    switch(direction)
        case 'NB'
            fid = fopen('CaltrianNBSchedule.bin','r');
        otherwise
            fid = fopen('CaltrianSBSchedule.bin','r');
    end

    fseek(fid,0,1); n_bytes = ftell(fid);  fseek(fid,0,-1);
    n_stops = (n_bytes/8)/(n_stations+1);
    [trains,count] = fread(fid,[n_stops,n_stations+1],'double');
    fclose(fid);

    out_sched = trains(:,2:end);
    out_trains = num2str(trains(:,1));
end

function [Train_in] = get_stops(Train_in, sched, Stations)

    times = [];
    stations = {};
    
    for i = 1:size(sched,2)
        if ~isnan(sched(1,i))
            times = [times; sched(1,i)];
            if strcmp(Train_in.direction, 'NB')
                stations = [stations; Stations(i,1).name];
            else
                stations = [stations; Stations(length(Stations)-i+1,1).name];
            end
        end
    end
    
    Train_in.times = times;
    Train_in.stations = stations;
    
end