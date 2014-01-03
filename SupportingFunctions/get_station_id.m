function [station_id] = get_station_id(station, Stations)
%
% function: get_station_id
%
% purpose:  get the station ID corresponding to a station name
%

station_id = 0;

for i = 1:length(Stations)
    if strcmp(Stations(i).name,station)
        station_id = i;
        break
    else
        for j = 1:length(Stations(i).aliases)
            if strcmp(Stations(i).aliases{j},station)
                station_id = i;
                break
            end
        end
        
    end
end