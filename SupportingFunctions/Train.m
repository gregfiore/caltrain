classdef Train < handle
    
    properties
        number = 0;
        direction = 'NB';
        stations = [];
        times = [];
        users = [];
    end
    
    methods
        function t = Train(direction, number)
           t.direction = direction;
           t.number = str2double(number);
        end
        
        function sched_time = get_station_time(train, station_name)
            station_id = find(strcmp(train.stations,station_name)==1);
            
            sched_time = train.times(station_id);
            
        end
        
        function output_time = stops_here(train, station_name)

            a = strcmp(station_name, train.stations);
            output_time = train.times(a == 1);

        end
        
        function [] = print_stop(train, station_names)
            
            if iscell(station_names)
                disp(['#',num2str(train.number),' leaves ',station_names{1}, ' at ',daytime2str(train.stops_here(station_names{1})),...
                                                ' // arrives ',station_names{2}, ' at ',daytime2str(train.stops_here(station_names{2}))])

            else
                disp(['#',num2str(train.number),' is at ',station_names, ' at ',daytime2str(train.stops_here(station_names))])
            end
        end
    end
end
        