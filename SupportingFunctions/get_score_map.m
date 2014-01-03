function score_map = get_score_map(type)

    switch type
        case 'Station Names'

            score_map.types = {'Identifier',....            % Its found
                               'Capitalization',...         % Is the first letter capitalized?
                               'Preceeding Spaces',...      % Does a space precede the station name?
                               'Following Characters',...   % Is the station name followed by a space, comma or period?
                               'Location'};                 % Where in the string is the station name located?

            score_map.scores = [3,...
                                5,...
                                3,...
                                5,...
                                0];

        case 'Trains'
            score_map.types = {'Identifier',...             % If its found
                               'Preceeding Spaces',...      % Is there a space before the number
                               'Preceeding Direction',...   % Is there a preceeding NB or SB
                               'Following Characters',...   % Is the station name followed by a space, comma or period?
                               'Location'};                 % Where in the string is the statio name located (preference toward early)
            
            score_map.scores = [4,...
                                2,...
                                6,...
                                4,...
                                2];
                            
        case 'Critical Incident'
            score_map.types = {'Identifier',...
                               'Preceeding Spaces'};
                           
            score_map.scores = [5,...
                                3];
    
        case 'Minor Incident'
            score_map.types = {'Identifier',...
                               'Preceeding Spaces'};
            
            score_map.scores = [5,...
                                3];
            
    end
        
end