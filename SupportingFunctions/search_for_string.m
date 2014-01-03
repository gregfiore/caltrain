function locations = search_for_string(input_string, string_to_find, direction, option)

locations = [];

idx = strfind(input_string, string_to_find);

if isempty(idx)
    return
else
    switch direction
        case 1
            if strcmpi(option,'first')
                locations = idx(1);
            else
                locations = idx;
            end
        case -1
            if strcmpi(option,'first')
                locations = idx(end);
            else
                locations = fliplr(idx);
            end
    end
end

