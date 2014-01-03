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
        % predicted meaning
        % true meaning
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Tweet object initialization %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function t = Tweet(inputTweet)
            t.origText = inputTweet;
            [t.timestamp,idx] = extractTimeStamp(t.origText);
            t.remainingText = t.origText(1:idx-1);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % process tweet information %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function t = processTweet(t)
            
            t.associatedStations = getStationReferences(t.remainingText);
            t.associatedTrains = getTrainReferences(t.remainingText);
            
            t.strippedText = stripText(t.remainingText);
            
%             t.printTrainReferences;
%             t.printStationReferences;
%             t.criticalIncidents = getCriticalIncidentReferences(t.remainingText);
%             t.minorIncidents = getMinorIncidentReferences(t.remainingText);
            
            
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
            if iscell(t.associatedStations)
                for i = 1:size(t.associatedStations,1)
                    disp(['Reference to ',t.associatedStations{i,1},...
                        ' at index ',num2str(t.associatedStations{i,2}(1))]);
                end
                
            else
                for i = 1:length(station_aliases)
                    if t.associatedStations(i,1)
                        disp(['Reference to ',station_aliases{i,1}{1},...
                            ' at index ',num2str(t.associatedStations(i,2)),...
                            ' with score ',num2str(t.associatedStations(i,1))])
                    end
                end
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
                
                if iscell(t.associatedTrains)

                    for i = 1:size(t.associatedTrains,1)
                        disp(['Reference to ',t.associatedTrains{i,1},...
                            ' at index ',num2str(t.associatedTrains{i,3}(1))]);
                    end
                    
                else
                    
                    % Type 1:  look for only recognized trains
                    % Northbound trains
                    for i = 1:length(NBtrains)
                        if t.associatedTrains.nb(i,1)
                            disp(['Reference to NB ',num2str(NBtrains(i).number),...
                                ' at index ',num2str(t.associatedTrains.nb(i,2)),...
                                ' with score ',num2str(t.associatedTrains.nb(i,1))])
                        end
                    end
                    
                    % Southbound trains
                    for i = 1:length(SBtrains)
                        if t.associatedTrains.sb(i,1)
                            disp(['Reference to SB ',num2str(SBtrains(i).number),...
                                ' at index ',num2str(t.associatedTrains.sb(i,2)),...
                                ' with score ',num2str(t.associatedTrains.sb(i,1))])
                        end
                    end
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
    timestamp = timestr2day(tweetText(idx+1:end));
    
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
function related_stations = getStationReferences(input_text)

%     % Aliases for each station
%     station_aliases = get_station_aliases;
%     
%     % Get current scoring values for each parameter
%     score_map = get_score_map('Station Names');
%     
%     % Array for the score and location of each station
%     related_stations = zeros(length(station_aliases),2);
%     
%     for i = 1:length(station_aliases)
%         
%         current_score = 0;
%         
%         for k = 1:length(station_aliases{i})
%                         
%             % Search for the station alias in the string
%             idx = search_for_string(input_text, station_aliases{i}{k}, 1,'');
%             
%             if length(idx) > 1
%                 disp(['Multiple matches for ',station_aliases{i}{k}]);
%             end
%             
%             if idx 
%                 alias_score = compute_score(input_text,...
%                                             station_aliases{i}{k},...
%                                             idx,...
%                                             score_map);
%                                         
%                 if alias_score > current_score
%                     current_score = alias_score;
%                     related_stations(i,:) = [current_score, idx];
%                 end
%             end
%             
%         end
%     end

    % Aliases for each station
    station_aliases = get_station_aliases;
    
    % Array for the score and location of each station
    related_stations = {};
    
    for i = 1:length(station_aliases)
                
        for k = 1:length(station_aliases{i})
                        
            % Search for the station alias in the string
            idx = search_for_string(input_text, station_aliases{i}{k}, 1,'');
            
            if length(idx) > 1
                disp(['Multiple matches for ',station_aliases{i}{k}]);
            end
            
            if idx 
                related_stations = [related_stations; {station_aliases{i}{k}}, {[idx, idx+length(station_aliases{i}{k})-1]}];
            end
            
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getTrainReferences        %
% ------------------        %
% Find references to trains %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function related_trains = getTrainReferences(input_text)

%     global NBtrains
%     global SBtrains

    [related_trains] = identifyTrains(input_text);
%     
%     % Get the score map for the trains
%     score_map = get_score_map('Trains');
% 
%     % Find NB trains
%     nb_id = strfind(lower(input_text),'nb');
%     related_trains.nb = {};
%     
%     for i = 1:length(nb_id)
%         if ( ~isempty(str2num(input_text(nb_id(i)+2))) && ...
%              ~isempty(str2num(input_text(nb_id(i)+3))) && ...
%              ~isempty(str2num(input_text(nb_id(i)+4))) )
%             % NBXXX
%             train_num = str2num(input_text(nb_id(i) + (2:4)));
%             
%             related_trains.nb = [related_trains.nb; {input_text(nb_id(i):(nb_id(i) +4))}, {nb_id(i)}, {nb_id(i) + 4}, {0}];
%     
%         elseif ( ~isempty(str2num(input_text(nb_id(i)+3))) && ...
%                  ~isempty(str2num(input_text(nb_id(i)+4))) && ...
%                  ~isempty(str2num(input_text(nb_id(i)+5))) )
%             % NB XXX
%             train_num = str2num(input_text(nb_id(i) + (3:5)));
%             
%             related_trains.nb = [related_trains.nb; {input_text(nb_id(i):(nb_id(i) +5))}, {nb_id(i)}, {nb_id(i) + 5}, {train_num}, {0}];
%         
%         elseif ( ~isempty(str2num(input_text(
%         
%         
%         
%         else
%             related_trains.nb = [related_trains.nb; {input_text(nb_id(i):(nb_id(i) +1))}, {nb_id(i)}, {nb_id(i) + 1}, {0}, {0}];
%         end
%             
%     end
%  
%     % Find SB trains
%     sb_id = strfind(lower(input_text),'sb');
%     related_trains.sb = {};
%     
%     for i = 1:length(sb_id)
%         if ( ~isempty(str2num(input_text(sb_id(i)+2))) && ...
%              ~isempty(str2num(input_text(sb_id(i)+3))) && ...
%              ~isempty(str2num(input_text(sb_id(i)+4))) )
%             
%             train_num = str2num(input_text(sb_id(i) + (2:4)));
%             
%             related_trains.sb = [related_trains.sb; {input_text(sb_id(i):(sb_id(i) +4))}, {sb_id(i)}, {sb_id(i) + 4}, {0}];
%     
%         elseif ( ~isempty(str2num(input_text(sb_id(i)+3))) && ...
%                  ~isempty(str2num(input_text(sb_id(i)+4))) && ...
%                 ~isempty(str2num(input_text(sb_id(i)+5))) )
%             
%             train_num = str2num(input_text(sb_id(i) + (3:5)));
%             
%             related_trains.sb = [related_trains.sb; {input_text(sb_id(i):(sb_id(i) +5))}, {sb_id(i)}, {sb_id(i) + 5}, {train_num}, {0}];
%         else
%             related_trains.sb = [related_trains.sb; {input_text(sb_id(i):(sb_id(i) +1))}, {sb_id(i)}, {sb_id(i) + 1}, {0}, {0}];
%         end
%             
%     end
%     
%     related_trains.nb = zeros(length(NBtrains),3);  % Score, index Start, index Stop
%     related_trains.sb = zeros(length(SBtrains),3);
% 
%     % Search for NB train references
%     for i = 1:length(NBtrains)
% 
%         idx = search_for_string(input_text, num2str(NBtrains(i).number), 1,'');
% 
%         if idx
%             
%             [direction, dir_id] = findDirection(input_text,idx);
%             
%             if dir_id
%             
%                 train_score = compute_score(input_text,...
%                     [input_text(dir_id:idx+2)],...
%                     idx, ...
%                     score_map);
% 
%                 related_trains.nb(i,:) = [train_score(1), dir_id, idx(1)+2];
%             else
%                 
%                 train_score = compute_score(input_text,...
%                     [input_text(dir_id:idx+2)],...
%                     idx, ...
%                     score_map);
% 
%                 related_trains.nb(i,:) = [train_score(1), dir_id, idx(1)+2];                
%         end
% 
%     end
% 
%     % Search for SB train references
%     for i = 1:length(SBtrains)
% 
%         idx = search_for_string(input_text, num2str(SBtrains(i).number), 1,'');
% 
%         if idx
%             
%             [direction, dir_id] = findDirection(input_text,idx);
% 
%             train_score = compute_score(input_text,...
%                 [input_text(dir_id:idx+2)],...
%                 idx, ...
%                 score_map);
% 
%             related_trains.sb(i,:) = [train_score(1), idx(1)];
%         end
% 
%     end
%     
%     % Search for incorrect train references
%     related_trains.other = {};
% 
%     idx = search_for_string(
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getCriticalIncidentReferences         %
% ------------------                    %
% Find references to critical indicents %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function incidents = getCriticalIncidentReferences(input_text)

    critical_incidents = get_critical_events;
    score_map = get_score_map('Critical Incident');

    incidents = zeros(length(critical_incidents),2);
    
    for i = 1:length(critical_incidents)
                    
            % Search for the station alias in the string
            idx = search_for_string(input_text, critical_incidents{i,1}, 1,'');
            
            if length(idx) > 1
                disp(['Multiple matches for ',critical_incidents{i,1j}]);
            end
            
            if idx
                alias_score = compute_score(input_text,...
                    critical_incidents{i,1},...
                    idx,...
                    score_map);
                
                current_score = alias_score;
                incidents(i,:) = [current_score*critical_incidents{i,2}/5, idx];
            end
                    
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getMinorIncidentReferences            %
% ------------------                    %
% Find references to minor indicents    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function incidents = getMinorIncidentReferences(input_text)

    incidents = [];

    minor_incidents = get_minor_events;          % 3x1 strucgure of different types of references
    score_map = get_score_map('Minor Incident');
    
    fields = fieldnames(minor_incidents);        % For each structure field look for incidents and assign score
    
    for i = 1:length(fields)
        
        temp_field = getfield(minor_incidents,fields{i});
        
        temp_incidents = zeros(length(temp_field),2);
        
        for j = 1:length(temp_field)
            
            idx = search_for_string(input_text, temp_field{j}, 1, '');
            
            if length(idx) > 1
                disp(['Multiple matches for ',temp_field{j}])
            end
            
            if idx
                current_score = compute_score(input_text,...
                                            temp_field{j} ,...
                                            idx,...
                                            score_map);
                                        
                temp_incidents(j,:) = [current_score, idx];
            end
        end
    
        incidents = setfield(incidents,fields{i},temp_incidents);
      
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stripText                                          %
% ---------                                          %
% Strip station and train references from tweet text %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = stripText(t)
a = 1;
    for i = 1:size(t.associatedTrains)


    end
end
