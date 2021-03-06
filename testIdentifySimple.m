function [] = testIdentifySimple()

clear all; close all; loadCTdata; main_caltrain_process;

ts = 5/60/24;

t_start = datenum('1-Jun-2011 00:00:00');
t_stop = datenum('23-Dec-2011 23:59:59');

t = t_start:ts:t_stop;

last_time = t(1);

t_times = zeros(length(raw),1);
for i = 1:length(raw)
     t_times(i) = raw{i,4};
end

% I am trying to go through and simulate the chronology of receiving tweets
% % and processing them.  If there are new tweets to process, read them in and determine 
% their meaning.  If there is already an event in place, then don't do anything, 
% otherwise, notify users.
total_tweets = 0;
cip = 0;            % Critical event in progress flag
cip_cnt = 0;        % Counter of time in CIP
cip_time = 2.5/24;  % Two hour block
c_threshold = 1;    % Threshold for critical event
cip_cnt_d = zeros(length(t),1);
c_cnt = 0;          % Count of critical events

for i = 2:length(t)
    
    current_time = t(i);
    cip_cnt_d(i) = cip_cnt;
    
    % Deal with CID flag first
    if cip
        if cip_cnt > cip_time
            cip = 0;    % The timer has expired, clear the flag
            cip_cnt = 0;
        else
            cip_cnt = cip_cnt + (current_time - last_time); % Timer hasn't expired, keep incrementing
        end
    end
    
    
    t_ids = getNewTweets(current_time,last_time,t_times);
    
    
    if ~isempty(t_ids)
        newTweets = raw(t_ids,:);
        total_tweets = total_tweets + length(t_ids);

        for j = length(t_ids):-1:1
            tweet = Tweet(newTweets{j,2});
            tweet.processTweet;
            
            if sum(tweet.criticalIncidents) >= c_threshold
                c_cnt = c_cnt + 1;
                % Critical Event Identified
                if cip
%                     disp([datestr(current_time),' --Critical event identified, CIP -- no action taken'])
                else
                    % Trigger a CIP
                    cip = 1;
                    t_ids(j)
                    disp([datestr(current_time),' ** Critical Event Notification **'])
                    disp(['Triggered by Tweet: ',tweet.remainingText])
                    disp(['In effect from ',datestr(current_time),' to ',datestr(current_time + cip_time)])
                end
            end
        end
    end
    
    last_time = current_time;
end

a = 1;

function t_ids = getNewTweets(current_time,last_time,t_times)

% Find tweets between last time and current time

t_ids = find(last_time < t_times & t_times <= current_time);
    
    