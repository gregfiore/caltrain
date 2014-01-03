function [output_time, output_day] = gmt_to_pst(input_time, input_day)
% Convert GMT time to PST time

gmt_hour = input_time(4);
pst_hour = gmt_hour - 8;

output_time = input_time;

if pst_hour < 0
    pst_hour = 24 + gmt_hour - 8;
    output_day = input_day - 1;
    temp = datevec(output_day);
    output_time(4) = pst_hour;
    output_time(1:3) = temp(1:3);
else
    output_time(4) = pst_hour;
    output_day = input_day;
end