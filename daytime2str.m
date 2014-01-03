function [time_str,mins_out] = daytime2str(input_time)
% Convert the time in days to a HH:MM format

hrs = floor(input_time*24);
mins = round((input_time - hrs/24)*(24*60));

hrs_str = num2str(hrs);
mins_str = num2str(mins);

if length(hrs_str) == 1
    hrs_str = ['0',hrs_str];
end

if length(mins_str) == 1
    mins_str = ['0',mins_str];
end

time_str = [hrs_str,':',mins_str];
mins_out = hrs * 60 + mins;

function [output_time] = timestr2day(input_str)

colon_id = strfind(input_str,':');

hrs = str2double(input_str(colon_id + (-2:-1)));
mins = str2double(input_str(colon_id + (1:2)));

output_time = (hrs + mins/60)/24;

if output_time > 1
    output_time = output_time - 1;
end