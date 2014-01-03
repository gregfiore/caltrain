function words = getWords(tweet);

    badnames = ' ,.\;)"&';

    spaces = isspace(tweet);

    space_ids = find(spaces == 1);

    words = cell(length(space_ids)+1,1);

    if space_ids

        words{1} = tweet(1:space_ids(1)-1);
        words{end} = tweet(space_ids(end)+1:end);
    else
        words{1} = tweet(1:end);
    end


    for i = 2:length(space_ids)

        temp = tweet( (space_ids(i-1) + 1):(space_ids(i) - 1));

        if length(temp) == 0;
            break
            % disregard
        end

        words{i} = temp;

    end

    % Remove any empty cells
    e_cells = [];

    for i = 1:length(words)
        e_cells = [];

        if isempty(words{i})
            e_cells = [e_cells; i];
        end

        temp = words{i};

        % Remove any bad characters
        for j = 1:length(badnames)
            b_ids = strfind(temp, badnames(j));
            if b_ids
                %                 disp(['Removing instances of "',badnames(j),'".'])
                temp(b_ids) = [];
            end
        end

        words{i} = lower(temp);

    end

    words(e_cells) = [];

end