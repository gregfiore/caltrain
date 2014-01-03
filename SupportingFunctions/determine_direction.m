function direction  = determine_direction(departing_station, arriving_station, Stations)
%
% Function:  determine_direction
%
% Purpose:  determine what direction train goes between the departing and
%           arriving stations
%

% find the indices of the stations
[depart_id] = get_station_id(departing_station, Stations);
[arrive_id] = get_station_id(arriving_station, Stations);

if depart_id > arrive_id
    direction = 'SB';
else
    direction = 'NB';
end
