classdef User < handle
    
    properties
        username = '';                  % User name
        useremail = '';                 % User email
        userapn = 0;                    % User device APN identifier
        notificationSetting = [0 0];    % Notification settings
        commDir = 0;                    % To-work communte direction (0 is NB)
        homeStation = '';               % home Station
        workStation = '';               % Work Station
        workTimeEarly = 0;              % Work-bound times
        workTimeLate = 0;
        homeTimeEarly = 0;              % Home-bound times
        homeTimeLate = 0;
        trains = 0;                     % Trains
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % User object initialization %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function u = User(username,userapn)
            % Two inputs:  User('username',userapn)
            u.username = username;
            u.userapn = userapn;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        % User set commute parameters %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function u = setCommute(u,varargin)
            n_param = floor((nargin-1)/2);
            if n_param ~= (nargin-1)/2
                disp('Error, too many inputs')
            end
            for i = 1:n_param
                if isnumeric(varargin{2*i})
                    eval(['u.',varargin{2*i-1},'=',num2str(varargin{2*i}),';']);
                else
                    eval(['u.',varargin{2*i-1},'=''',varargin{2*i},''';']);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%
        % Update the trains %
        %%%%%%%%%%%%%%%%%%%%%
        function u = updateTrains(u)
            global Stations
            global NBtrains
            global SBtrains

            [blah, wTrains] = find_trains(u.homeStation,u.workStation,u.workTimeEarly, (u.workTimeLate - u.workTimeEarly));
            [blah, hTrains] = find_trains(u.workStation,u.homeStation,u.homeTimeEarly, (u.homeTimeLate - u.homeTimeEarly));
            
            u.trains = [wTrains; hTrains];
            

        end     
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display user information %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [] = dispUser(u)
            disp('%%%%%%%')
            disp(['User: ',u.username,' with AP ID ',num2str(u.userapn)])
            disp(['Leaves ',u.homeStation,' between ',daytime2str(u.workTimeEarly),' and ',daytime2str(u.workTimeLate)])
            disp(['Comes home from ',u.workStation,' between ',daytime2str(u.homeTimeEarly),' and ',daytime2str(u.homeTimeLate)])
            disp(['Rides on ',num2str(length(u.trains)),' trians'])
            if u.notificationSetting(1)
                disp(['IS subscribed to critical notifications.'])
            end
            if u.notificationSetting(2)
                disp('IS subscribed to train-specific notifications.')
            end
            disp('%%%%%%%')
        end
        
    end
    
end