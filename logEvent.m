function [] = logEvent(tweet, event_type, print_flag)

max_file_size = 1e6;

try 
    fid_all = evalin('base','event_log_fid');
    fid = fid_all(end);
    if ftell(fid) > max_file_size
        % the file is too big, make a new one
        fclose(fid);
        fid = fopen(['CaltrainEventLog_',datestr(now,30),'.log'],'w');
        fid = [fid_all; fid];
    end
catch
    fid = fopen(['CaltrainEventLog_',datestr(now,30),'.log'],'w');
    assignin('base','event_log_fid',fid);
end

switch event_type
    case 'CI'
        fprintf(fid,'%s : %s Notified users of CRITICAL EVENT %s\n',datestr(now,31),datestr(tweet.origDate,2),tweet.origText);
        if print_flag
            % print to the desktop
            fprintf('%s : %s Notified users of CRITICAL EVENT %s\n',datestr(now,31),datestr(tweet.origDate,2),tweet.origText);
        end
    case 'CI_r'
        fprintf(fid,'%s : %s Identified redundant CRITICAL EVENT %s\n',datestr(now,31),datestr(tweet.origDate,2),tweet.origText);
        if print_flag
            % print to the desktop
            fprintf('%s : %s Identified redundant CRITICAL EVENT %s\n',datestr(now,31),datestr(tweet.origDate,2),tweet.origText);
        end        
    case 'MI'
        fprintf(fid,'%s : %s Notified users of Minor Event involving train in tweet %s\n',datestr(now,31),datestr(tweet.origDate,2),tweet.origText);
        if print_flag
            % print to the desktop
            fprintf('%s : %s Notified users of Minor Event involving train in tweet %s\n',datestr(now,31),datestr(tweet.origDate,2),tweet.origText);
        end
    
end


end