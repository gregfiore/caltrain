function [num_out, indices] = findDigits(input_string, l_digits)
%
% Function findDigits
%
% Purpose:  find L consecutive numeric characters in the input string
%
% Inputs:   - input_string (the string to be processed)
%           - l_digits (the number of consecutive digits desired)
%
% Outputs:  - num_out (cell array of identififed numbers)
%           - indices (Nx2 matrix of start and end indices of identified numbers)
%

% Initialize variables
cnt = 1;        % Counter for position in input_string
num_out = {};   % Output cell array of valid numbers
indices = [];   % Start and end indices of valid numbers

while cnt <= length(input_string)
    found_flag = 0;  % flag indicating a valid numeric string has been found
    if ~isempty(str2num(input_string(cnt)))  ||   strcmpi(input_string(cnt),'x')
        if cnt + l_digits - 1 > length(input_string)
            % We've reached the end of the string, just stop.
            return
        end
        for i = 1:l_digits-1
            if ~isempty(str2num(input_string(cnt+i))) || strcmpi(input_string(cnt+i),'x')
               % this is good, keep going
               % X's are sometimes used in place of unknown numbers, so
               % count these as valid too
            else
                % not a valid string, start looking again
                cnt = cnt + i;
                found_flag = 0;
                break
            end
            found_flag = 1;
        end
        if found_flag
            % If you get this far, it's a valid l_digit (at least) number
            if cnt+i == length(input_string)
                num_out = [num_out; input_string(cnt:(cnt+i))];
                indices = [indices; cnt, cnt+i];
                return
            elseif isempty(str2num(input_string(cnt+i+1))) || ~strcmpi(input_string(cnt+i),'x')
                % This is the end of the digits
                num_out = [num_out; input_string(cnt:(cnt+i))];
                indices = [indices; cnt, cnt+i];
                cnt = cnt + i + 1;

            end
        end
    else
        cnt = cnt + 1;
    end
    
    
end