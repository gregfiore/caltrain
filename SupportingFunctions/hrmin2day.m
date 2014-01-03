function [output_time] = hrmin2day(hrs, mins)
%
% Function: timestr2day
%
% Purpose: convert a time in hours and minutes to fraction of a day
%

output_time = (hrs + mins/60)/24;

if output_time > 1
    output_time = output_time - 1;
end
