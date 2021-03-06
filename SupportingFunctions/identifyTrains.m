function [identified_trains] = identifyTrains(input_string)

% 1.  Find 3-digit train references
% 2.  Find NB/SB direction references
% 3.  Match trains with known train schedule

% Outputs:  
%       1.  Train Text     (string)
%       2.  Matched Number (double)
%       3.  Incides of train text (1x2 double)

global NBtrains;
global SBtrains;

identified_trains = {};

% Find 3-digit train references
[num_out, num_idx] = findDigits(input_string, 3);

% Find the NB/SB direction references
for i = 1:size(num_out,1)
    % get all NB/SB references before this string
    [direction, index] = findDirection(input_string,num_idx(i,1),5);
    
    if ~isempty(direction)
        % a direction was found preceding the numbers
        identified_trains = [identified_trains; {[direction{1},num_out{i}]}, {0},{[index(1), num_idx(i,1)+2]}];
    else
       % a direction wasn't found
       identified_trains = [identified_trains; {num_out{i}}, {0}, {[num_idx(i,1), num_idx(i,2)]}];
    end
end

% Validate train references

for i = 1:size(identified_trains,1)
    if length(identified_trains{i,1}) == 5
        train_num = str2double(identified_trains{i,1}(3:5));
    else
        train_num = str2double(identified_trains{i,1}(1:3));
    end
    
    for j = 1:length(NBtrains)
        if train_num == NBtrains(j).number
            identified_trains{i,2} = NBtrains(j).number;
        end
    end
        
    for j = 1:length(SBtrains)
        if train_num == SBtrains(j).number
            identified_trains{i,2} = SBtrains(j).number;
        end
    end
end