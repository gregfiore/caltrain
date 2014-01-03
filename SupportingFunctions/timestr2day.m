function [output_time] = timestr2day(input_str)
%
% Function: timestr2day
%
% Purpose: convert a time string AB:XY to fractions of a day
%
colon_id = strfind(input_str,':');

hrs = str2double(input_str(colon_id + (-2:-1)));
mins = str2double(input_str(colon_id + (1:2)));

output_time = (hrs + mins/60)/24;

if output_time > 1
    output_time = output_time - 1;
end
