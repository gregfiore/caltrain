function [avail_trains, train_nos] = find_trains(varargin)
%
% Function: find_trains
%
% Purpose:  Find trains at a specific time that are going between two
% stations
% 
% Inputs:  departing_station (string name of departing station)
%          arriving_station (string name of arriving station)
%          train_time (optional input of the departure time -- otherwise the current time is used)
%          tolerance (optional input for the amount of time after the departure time -- otherwise 1 hr is used)
%

    departing_station = varargin{1};
    arriving_station = varargin{2};
%     trains = varargin{3};
    
    if nargin == 2
        temp = clock;
        train_time = hrmin2day(temp(4),temp(5));
        tolerance = 1/24;
    else
        train_time = varargin{3};
        if nargin == 3
            tolerance = 1/24;
        else
            tolerance = varargin{4};
        end
    end


    global Stations NBtrains SBtrains
    
    direction  = determine_direction(departing_station, arriving_station, Stations);
    switch direction
        case 'NB'
            trains = NBtrains;
        otherwise 
            trains = SBtrains;
    end
    
    avail_trains = [];
    train_nos = [];


    for i = 1:length(trains)
        % get stops at departure station
        dep = trains(i).stops_here(departing_station);
        arr = trains(i).stops_here(arriving_station);

        if ~isempty(dep) && ~isempty(arr)
            if dep >= train_time && dep <= (train_time + tolerance)
                avail_trains = [avail_trains; trains(i)];
%                 trains(i).print_stop({departing_station, arriving_station});
                train_nos = [train_nos; trains(i).number];
            end
        end
    end

end