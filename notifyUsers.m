function [] = notifyUsers(varargin)

    % Inputs
    %
    % 1.  Event Type Flag (0 =  critical event)
    % 2.  Tweet object
    % 3.  List of users to notify (user APN number)
    % 4.  If a CI:  an optional specific user to test notification
    %     Else:     the current train object associated with notification
    % 5.  If not CI:  an optional specific user to test notification

    user_list = varargin{3};
    tweet = varargin{2};
    global users
    userapns = [users.userapn];
        
    if ~varargin{1}
        % This is a critical event
        if nargin == 3
            % -- SEND CRITICAL NOTIFICATION -- 
            %fprintf('Caltrain: Major Delays Reported - %s\n',tweet.origText)
            
            % for i = 1:lenght(user_list)
            % find the right user
            % determine if its within (homeTimeEarly-2) and (homeTimeLate)
            % determine if its withing (workTImeEarly-2) and (workTimeLate)
            % if either of these is true, notify the user
            % end
        end
        
        if nargin == 4
            specific_user = varargin{4};
            if find(user_list == specific_user)
                % Do the same thing as above, send the notification.
                % If the user specified is in the CI notificaion list, send him a notification
                fprintf('Caltrain: Major Delays Reported - %s\n',tweet.origText)
            end
        end
    else
        current_train = varargin{4};
        % This is a minor event notification
        for i = 1:length(user_list)
            if users(userapns == user_list(i)).notificationSetting(2)
%                 [station,time] = userTrainMeet(users(userapns == user_list(i)), current_train);
                % -- SEND USER NOTIFICATION --
                % fprintf('Caltrain: Your Train %d (%s @ %s) may be impacted\n',current_train.number, station, time)
            end
        end
        if nargin == 5
                specific_user = varargin{5};
            if find(user_list == specific_user)
                if users(specific_user == userapns).notificationSetting(2)
                    [station,time] = userTrainMeet(users(specific_user == userapns), current_train);
                    fprintf('%s Caltrain: Your Train %d (%s @ %s) may be impacted - %s\n',datestr(tweet.origDate,2),current_train.number, station, time, tweet.origText)
                end
            end
        end
    end
        
end


function [station,time] = userTrainMeet(user, train)

    switch user.commDir
        case 0
            %North Bound commute to work
            if strcmp(train.direction,'NB')
                % North bound train & North bound commute to work 
                % The person boards this train at his home station
                station = user.homeStation;
            else
                % South bound train & north bound commute to work
                % The person boards this train on his way home from work
                station = user.workStation;
            end
        case 1
            % South bound commute to work
            if strcmp(train.direction,'NB')
                % North bound train, south bound commute
                % User boards this train on his way home from work
                station = user.workStation;
            else
                % South bound train, south bound commute
                % User boards this train on his way to work
                station = user.homeStation;
            end        
    end
    
    time = daytime2str(train.get_station_time(station));

end