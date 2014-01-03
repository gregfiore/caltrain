function [direction, index] = findDirection(input_text,idx,thresh)
%
% findDirection
%
% Extract the leading train direction text from the input string
%
% Input: input_text (entire input string to search)
%        idx (index of the matching train number)
%        thresh (how close it must be to the idx)
%
% Output: direction ('NB' or 'SB')
%         index (position of the NB or SB text)
%

direction = {};
index = [];

nb_id = strfind(lower(input_text(1:idx)),'nb');
sb_id = strfind(lower(input_text(1:idx)),'sb');

for i = 1:length(nb_id)
    if (idx - nb_id(i)) < thresh
        direction = [direction; 'NB'];
        index = [index; nb_id(i)];
    end
end

for i = 1:length(sb_id)
    if (idx - sb_id(i)) < thresh
        direction = [direction; 'SB'];
        index = [index; sb_id(i)];
    end
end
