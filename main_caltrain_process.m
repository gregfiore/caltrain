function main_caltrain_process()

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configurable Parameters %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
isRealtime = 0;                                 % Procesing tweets in real time or processing old data?
tPeriod = 5;                                    % Seconds between executions (for realtime)
t_start = datenum('1-Jun-2011 00:00:00');       % Start time (for non-realtime)
% t_start = datenum('1-Jan-2012 00:00:00');     % Start time (for non-realtime)
t_stop = datenum('19-Apr-2012 23:59:59');       % Stop time (for non-realtime)
c_threshold = 1;                                % Threshold of critical words to trigger a notification
cip_time = 2.5/24;                              % Time a critical event is in progress
ci_leak = 5;                                    % points per hour
user_of_interest = 2;                           % User of interest for debugging and testing
fid = fopen('CaltrainPerformanceData.dat','w'); % File with the performance data
frame = [];                                     % Performance data frame

% In non-realtime mode, the processing is simulated at tPeriod

%%%%%%%%%%%%%%
% Initialize %
%%%%%%%%%%%%%%

global Stations NBtrains SBtrains users
Stations = initStations;
[NBtrains, SBtrains] = initTrains;
users = initUsers;
[NBtrains, SBtrains] = mapUsersToTrains(NBtrains, SBtrains, users);
CI_list = mapUsersToCI(users);

%%%%%%%%%%%%%%%%%%%%%%
% Processing Metrics %
%%%%%%%%%%%%%%%%%%%%%%
tweet_buffer_size = 3;        % moving average window size for tweet timing
tweet_time_buffer = zeros(tweet_buffer_size,1);    % moving average window
current_ci_count = 0;         % Current running sum of CI event points
cip = 0;                      % Default - not in effect
framecount = 0;
cip_cnt = 0;

% Set up the non-realtime data
if isRealtime == 0
    loadCTdata;     % Load the database of Caltrain Tweets
    
    % The "time" vector for executing the processing
    t = t_start:tPeriod/60/24:t_stop;
    last_time = t(1);
    
    % Extract the timestamp of each tweet
    t_times = zeros(length(raw),1);
    
    for i = 1:length(raw)
        t_times(i) = raw{i,4};
    end
    
    wb = waitbar(0,'None');

else
    last_time = 0;
end
%%%%%%%%%%%%%%%%%%%%
% Begin processing %
%%%%%%%%%%%%%%%%%%%%

while 1
    
    framecount = framecount + 1;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             Get Tweets                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    switch isRealtime
        case 1
            
            url_data = urlread('http://search.twitter.com/search.json?q=%40from:caltrain');
            url_data = loadjson(url_data);
            
            current_time = now;  % time of current processing
            
            % Add a "SINCE" category when its running so we dont do
            % anything if no tweets have come on the current day
            
            % Parse out the twitter feed data
            n_results = url_data.results_per_page;
            entries = url_data.results;
            twitter_data = cell(n_results,4);
            tweet_cnt = 1;
            
            for i = 1:n_results
                % note:  time is in GMT, not PST
                [output_time, output_day] = parse_caltrain_time(entries(i).created_at);
                [output_time, output_day] = gmt_to_pst(output_time, output_day);
                if output_time <= last_time
                    break
                end
                tweets(i) = Tweet(entries(i).text);
                tweets(i).origDate = output_day;
                tweets(i).origTime = output_time;
                tweets(i).processTweet;
            end
            
        case 0
            
            if framecount > length(t)
                break
            end
            
            current_time = t(framecount);  % time of current processing

            t_ids = getNewTweets(current_time,last_time,t_times);
            
            if ~isempty(t_ids)  % There are new tweets to look at
                for j = 1:length(t_ids)
                    tweets(j) = Tweet(raw{t_ids(length(t_ids)-j+1),2});;
                    tweets(j).processTweet;
                    tweets(j).origDate = datenum(raw{t_ids(length(t_ids)-j+1),1},2);
                    tweets(j).timestamp = tweets(j).timestamp + tweets(j).origDate;
                end
            end
            
            if mod(framecount,50) == 0
                wb = waitbar(framecount/length(t),wb, datestr(current_time));
            end
    end
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Process Notifications                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Process Critial Event In Progress (CIP) counter %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    if cip % Is an event in progress
        if cip_cnt > cip_time
            cip = 0;  % The timer has expired, clear the flag
            cip_cnt = 0;
            current_ci_count = 0;
        else  % It has not yet expired
            cip_cnt = cip_cnt + (current_time - last_time);  % Increment timer
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine if action is required %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist('tweets')   % Is there anything to process?
        for i = 1:length(tweets)
            [tweets_per_hour, tweet_time_buffer] = compTweetMA(tweet_time_buffer, tweets(i).timestamp);            
            delta_t = tweet_time_buffer(1) - tweet_time_buffer(2);  % Time between successive tweets
            current_ci_count = current_ci_count - ci_leak * delta_t*24;  % Decay critical incident counter
            if current_ci_count < 0
                current_ci_count = 0;
            end
            frame = [current_time, framecount, isRealtime, cip, cip_cnt, tweets(i).timestamp, tweets_per_hour, delta_t, tweets(i).criticalIncidents'];
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % Critical Incident COA %
            %%%%%%%%%%%%%%%%%%%%%%%%%
            current_ci_count = current_ci_count + sum(tweets(i).criticalIncidents);  % Counter of critical incident points
                        
            if current_ci_count >= c_threshold
                % This is a valid event
                if ~cip
                    cip = 1;  % trigger a critical event notification if one isn't already in progress
                    notifyUsers(0, tweets(i),CI_list,user_of_interest);
%                     logEvent(tweets(i),'CI',1);
                elseif sum(tweets(i).criticalIncidents) > 0
%                     logEvent(tweets(i),'CI_r',1);   % Redundant critical incident
                end
            end
            
            frame = [frame, current_ci_count];
            
            %%%%%%%%%%%%%%%%%%%%%%
            % Minor Incident COA %
            %                    %
            % NOTE:              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % It is possible that a user may not receive critical incident
            % notifications but still require notification of a minor event
            % concerning their train specifically 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            if cip
                users_notified = CI_list;   % CASE 1:  Don't notify users of minor events if a critical event is in progress
            else
                users_notified = [];        % CASE 1 & 2:  Notify users of minor incidents if there is no critical incicent in progress
            end
            
            for j = 1:size(tweets(i).associatedTrains,1)       % Each of the trains
                if tweets(i).associatedTrains{j,2}             % This has been recognized as a valid train number
                    if mod(tweets(i).associatedTrains{j,2},2)  % Even numbered trains are south bound
                        [current_train, train_id] = find_train_no(tweets(i).associatedTrains{j,2}, NBtrains);  % Matching train object
                    else
                        [current_train, train_id] = find_train_no(tweets(i).associatedTrains{j,2}, SBtrains);  % Matching train object
                    end
                    
                    if sum(tweets(i).minorIncidents)  % If there is a valid identifier word
                        % Notify the users of a minor event
                        users_to_notify = setdiff(current_train.users,users_notified);  % Only notify users who haven't been notified (CASE 1 & 3)
                        notifyUsers(1,tweets(i),users_to_notify,current_train,user_of_interest);
%                         logEvent(tweets(i),'MI',1);
                        users_notified = union(current_train.users,users_notified);     % Add these users to the list of users who have been notified
                    end
                end
            end
            
            frame = [frame, size(tweets(i).associatedTrains,1), tweets(i).minorIncidents'];
            fwrite(fid,frame);
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Set-up for next frame %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    clear tweets
    
    switch isRealtime
        case 1
            pause(tPeriod)
        otherwise
            % Do nothing
    end
    
    last_time = current_time;
 
end

%%%%%%%%%%%
% Cleanup %
%%%%%%%%%%%

fclose all;
close(wb);

end
      


function t_ids = getNewTweets(current_time,last_time,t_times)

% Find tweets between last time and current time

t_ids = find(last_time < t_times & t_times <= current_time);

end

function [output_time,output_day] = parse_caltrain_time(input_time)
% Parse the time from the Caltrain/Twitter time stamp

input_time(8) = '-';
input_time(12) = '-';

output_time = datevec(input_time(6:25),0);

output_day = datenum(input_time(6:16),1);
end

function [tweets_per_hour, tweet_time_buffer] = compTweetMA(tweet_time_buffer, input_time)

tweets_per_hour = 0;

% Do the shift
% [ NEWEST TWEET, ..... , OLDEST TWEET]
for i = length(tweet_time_buffer):-1:2
    tweet_time_buffer(i) = tweet_time_buffer(i-1);
end

tweet_time_buffer(1) = input_time;

% Is the buffer full?
if find(tweet_time_buffer == 0)
   return
else
    tweets_per_hour = -mean(diff(tweet_time_buffer))*24;  % (mean hours between tweets)
    if tweets_per_hour ~= 0
        tweets_per_hour = 1/tweets_per_hour;
    else
        tweets_per_hour = 60;  % 1 per minute
    end
end


end