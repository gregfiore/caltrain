function [] = extractIncidentProbs(input_data)


unique_words = {};
n_unique_ids = 0;
tweet_category_count = [0 0 0];
count_threshold = 1;

words = {'expect';...
    'transfer';...
    'rescue';...
    'passengers';...
    'struck';...
    'trespasser';...
    'stuck';...
    'delays';...
    'incident';...
    'site';...
    'fatality';...
    'pax';...
    'down';...
    'mins';...
    'departed';...
    'late';...
    'min';...
    'leaving';...
    'left';...
    'now';...
    'minutes';...
    '_Train';...
    '_Station'};

unique_words = cell(length(words),5);

unique_words(:,1) = words;

for i = 1:length(words)
    for j = 2:5
        unique_words{i,j} = 0;
    end
end


for i = 1:length(input_data)
    
    tweet_type = input_data{i,3};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Increment the instance of the correct category (cc) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if strcmp(input_data{i,3},'c')
        tweet_category_count(1) = tweet_category_count(1) + 1;
    elseif strcmp(input_data{i,3},'m')
        tweet_category_count(2) = tweet_category_count(2) + 1;
    elseif strcmp(input_data{i,3},'n')
        tweet_category_count(3) = tweet_category_count(3) + 1;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find any train or station references %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    temp = Tweet(input_data{i,2});
    try
        temp.processTweet;
    catch
        a = 1;
    end
    for j = 1:length(temp.associatedTrains.nb)
        if temp.associatedTrains.nb(j,1)   
            dir_id = strfind(lower(input_data{i,2}),'nb');
            if dir_id
                if temp.associatedTrains.nb(j,2) - dir_id < 5
                    input_data{i,2} = strrep(input_data{i,2},input_data{i,2}(dir_id:temp.associatedTrains.nb(j,2)+2),'_Train');
                end
            else
                input_data{i,2} = strrep(input_data{i,2},input_data{i,2}(temp.associatedTrains.nb(j,2)+(0:2)),'_Train');
            end
        end
    end
    for j = 1:length(temp.associatedTrains.sb)
        if temp.associatedTrains.sb(j,1)   
            
            dir_id = strfind(lower(input_data{i,2}),'sb');
            if dir_id
                if temp.associatedTrains.sb(j,2) - dir_id < 5
                    input_data{i,2} = strrep(input_data{i,2},input_data{i,2}(dir_id:temp.associatedTrains.sb(j,2)+2),'_Train');
                end
            else
                input_data{i,2} = strrep(input_data{i,2},input_data{i,2}(temp.associatedTrains.sb(j,2)+(0:2)),'_Train');
            end
        end
    end            
    
    
    % Extract the words from the tweet
    words = getWords(input_data{i,2});
    
    for j = 1:length(words)
        % Look for a match with existing unique words
        a = find(strcmp(words{j},unique_words) == 1);
        if a
            % This is not a unique word
            unique_words{a,2} = unique_words{a,2} + 1;
            
            % Increment the count of that particular word in the category (fc)
            if strcmp(input_data{i,3},'c')
                unique_words{a,3} = unique_words{a,3} + 1;
            elseif strcmp(input_data{i,3},'m')
                unique_words{a,4} = unique_words{a,4} + 1;
            elseif strcmp(input_data{i,3},'n')
                unique_words{a,5} = unique_words{a,5} + 1;
            else
                %                 disp(['Unidentified meaning ',input_data{i,3},' at ',num2str(i)])
            end
            
        end
    end
    
end

% Remove the words that don't occur often enough
word_count = cell2mat(unique_words(:,2));
thresh_id = find(word_count >= count_threshold);
unique_words = unique_words(thresh_id,:);


% Compute the probabilities

% The probability that a word is in a category is computed by dividing
% the number of times a word appeard in a document in that category by
% the total number of documents in that category

%     P ( word | category )
%
%     What is the probabilyt of "word" given "category"


for i = 1:length(unique_words)
    unique_words{i,3} = unique_words{i,3} / tweet_category_count(1);
    unique_words{i,4} = unique_words{i,4} / tweet_category_count(2);
    unique_words{i,5} = unique_words{i,5} / tweet_category_count(3);
end


P_category = tweet_category_count / sum(tweet_category_count);


save('ProbWord2.mat','unique_words','P_category')

end

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
