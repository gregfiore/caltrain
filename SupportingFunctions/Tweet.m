classdef Tweet < handle
    
    properties
        origDate = 0;               % original date stamp on tweet
        origTime = 0;               % original time stamp on tweet
        origText = '';              % original text in tweet
        timestamp = 0;              % time stamp in tweet text THH:MM 
        remainingText = '';         % tweet text without timestamp
        strippedText = '';          % tweet text with station and train references masked
        associatedStations = [];    % station references in text
        associatedTrains = [];      % trains referred to in text
        criticalIncidents = [];     % critical incident references
        minorIncidents = [];        % minor incident references
        extractedWords = {};        % extracted words from tweet
        % Configurable parameters
        removeRedundantWords = 1;        % remove redundant words in processing
        % predicted meaning
        % true meaning
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Tweet object initialization %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function t = Tweet(inputTweet)
            
            t.origText = inputTweet;
            
            % Remove carriage returns in tweet text
            t.origText(find(uint8(t.origText) == 13)) = [];
            t.origText(find(uint8(t.origText) == 10)) = [];
            
            [t.timestamp,idx] = extractTimeStamp(t.origText);
            t.remainingText = t.origText(1:idx-1);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % process tweet information %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function t = processTweet(t)
            
            [t.associatedStations, blah] = getStationReferences(t.remainingText);
            [t.associatedTrains, t.strippedText] = getTrainReferences(t.remainingText);
            [blah, t.strippedText] = getStationReferences(t.strippedText);
                        
            t.strippedText = strtrim(t.strippedText);
            
            t.extractedWords = getWords(t.strippedText);
            
            if t.removeRedundantWords
                try
                    t.extractedWords = unique(t.extractedWords);
                catch
                    a =1;
                end
                
            end
            
            t.criticalIncidents = getCriticalIncidentReferences(t.extractedWords);
            t.minorIncidents = getMinorIncidentReferences(t.extractedWords);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Print any references to a station %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [] = printStationReferences(t)
            
            if length(t.associatedStations) == 0
                disp('Tweet has not been processed yet.')
                return
            end
            
            % Aliases for each station
            station_aliases = get_station_aliases;
            
            disp('References to string: ')
            disp(t.remainingText)
            disp('==========================')
            for i = 1:size(t.associatedStations,1)
                disp(['Reference to ',t.associatedStations{i,1},...
                    ' at index ',num2str(t.associatedStations{i,2}(1))]);
            end

        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Print any references to a train   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [] = printTrainReferences(t)
            
                global NBtrains
                global SBtrains

                if length(t.associatedTrains) == 0
                    disp('Tweet has not been processed yet.')
                    return
                end
                disp('__________________________')
                disp('References to string: ')
                disp(t.remainingText)
                disp('==========================')
                

                for i = 1:size(t.associatedTrains,1)
                    disp(['Reference to ',t.associatedTrains{i,1},...
                        ' at index ',num2str(t.associatedTrains{i,3}(1))]);
                end

                disp('__________________________')
                                
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Print any references to critical incidents %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [] = printCriticalIncidentReferences(t)
            
            critical_incidents = get_critical_events;
            
            if length(t.criticalIncidents) == 0
                disp('Tweet has not been processed yet.')
                return
            end
            
            disp('References to string: ')
            disp(t.remainingText)
            disp('==========================')
            
            for i = 1:length(critical_incidents)
                if t.criticalIncidents(i,1)
                    disp(['Critical incident key word: "',critical_incidents{i,1},...
                        '" at index ',num2str(t.criticalIncidents(i,2)),...
                        ' with score ',num2str(t.criticalIncidents(i,1))])
                end
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Print any references to minor incidents    %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [] = printMinorIncidentReferences(t)
            
            minor_incidents = get_minor_events;
            
            if length(t.minorIncidents) == 0
                disp('Tweet has not been processed yet.')
                return
            end
            
            disp('References to string: ')
            disp(t.remainingText)
            disp('==========================')
            
            
            fields = fieldnames(t.minorIncidents);        % For each structure field look for incidents and assign score
            
            for i = 1:length(fields)
                
                temp_score = getfield(t.minorIncidents,fields{i});
                temp_names = getfield(minor_incidents,fields{i});
                                
                for j = 1:size(temp_score,1)
                    
                    if temp_score(j,1)
                   
                        disp(['Minor incident key word of type ',fields{i},': "',temp_names{j,1},...
                            '" at index ',num2str(temp_score(j,2)),...
                            ' with score ',num2str(temp_score(j,1))])
                    end
                end
                
            end
            
        end
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extractTimeStamp                          %
% ----------------                          %
% Extract time stamp from end of tweet text %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [timestamp,idx] = extractTimeStamp(tweetText)

    strlength = length(tweetText);
    idx = search_for_string(tweetText,'T',-1,'first');
    if ~isempty(idx) && (strlength-idx) < 7
        timestamp = timestr2day(tweetText(idx+1:end));
    else
        timestamp = '00:00';
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getTwitterStamp                                       %
% ----------------------------------------------------- %
% Extract the time stamp off the twitter JSON structure %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tweetDate, tweetTime] = getTwitterStamp(t)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getStationReferences        %
% ----------------------------%
% Find references to stations %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [related_stations, stripped_text] = getStationReferences(input_text)

    % Aliases for each station
    station_aliases = get_station_aliases;
    
    % Array for the score and location of each station
    related_stations = {};
    
    for i = 1:length(station_aliases)
                
        for k = 1:length(station_aliases{i})
                        
            % Search for the station alias in the string
            idx = search_for_string(input_text, station_aliases{i}{k}, 1,'');
            
            if length(idx) > 1
               % disp(['Multiple matches for ',station_aliases{i}{k}]);
                for j = 1:length(idx)
                    related_stations = [related_stations; {station_aliases{i}{k}}, {[idx(j), idx(j)+length(station_aliases{i}{k})-1]}];
                end
            elseif idx 
                related_stations = [related_stations; {station_aliases{i}{k}}, {[idx, idx+length(station_aliases{i}{k})-1]}];
            end
            
        end
    end
    
    idx_offset = 0;
    stripped_text = input_text;
    
    for i = 1:size(related_stations,1)
        
        idx = related_stations{i,2} + idx_offset;
        
        old_length = length(stripped_text);
        stripped_text(idx(1):idx(2)) = '';
        if idx(1) > 1
            stripped_text = [stripped_text(1:idx(1)-1),'_Station',stripped_text(idx(1):end)];
        else
            stripped_text = ['_Station',stripped_text(idx(1):end)];
        end
        new_length = length(stripped_text);
        
        idx_offset = idx_offset + new_length - old_length;
        
    end
    

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getTrainReferences        %
% ------------------        %
% Find references to trains %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [related_trains, stripped_text] = getTrainReferences(input_text)

    [related_trains] = identifyTrains(input_text);
    
    idx_offset = 0;
    stripped_text = input_text;
    
    for i = 1:size(related_trains,1)
        
        idx = related_trains{i,3} + idx_offset;
        
        old_length = length(stripped_text);
        stripped_text(idx(1):idx(2)) = '';
        if idx(1) > 1
            stripped_text = [stripped_text(1:idx(1)-1),'_Train',stripped_text(idx(1):end)];
        else
            stripped_text = ['_Train',stripped_text(idx(1):end)];
        end
        new_length = length(stripped_text);
        
        idx_offset = idx_offset + new_length - old_length;
        
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getCriticalIncidentReferences         %
% ------------------                    %
% Find references to critical indicents %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function incidents = getCriticalIncidentReferences(input_words)

    [critical_incidents, weights] = get_critical_events;
    
    incidents = zeros(length(critical_incidents),1);
    
    for i = 1:length(input_words)
        a = find(strcmp(input_words{i},critical_incidents) == 1);
        if a
            incidents(a) = incidents(a) + weights(a);
        end
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getMinorIncidentReferences            %
% ------------------                    %
% Find references to minor indicents    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function incidents = getMinorIncidentReferences(input_words)

    minor_incidents = get_minor_events;          % 3x1 strucgure of different types of references

    incidents = zeros(length(minor_incidents),1);
    
    for i = 1:length(input_words)
        a = find(strcmp(input_words{i},minor_incidents) == 1);
        if a
            incidents(a) = incidents(a) + 1;
        end
    end

end
