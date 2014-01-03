function [] = predictMeaning(input_data)

% Compute the probabilities that each word in the tweets corresponds to a
% specific meaning


% Notes
%
% - consider looking for station names and train references and use just
%   the existence of any station or train as a point for identification

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the unique words (featuers)                 %
% Count the features (words) in each category (fc) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
load ProbWord1.mat


    predictions = cell(length(input_data),6);
    n_words_thresh = 2;

    % Now try to classify each one
    for i = 1:length(input_data)

        predictions{i,1} = input_data{i,3};  % Truth classification

        words = getWords(input_data{i,2});   % Extract the words

        probs = [1, 1, 1];
        n_valid_words = 0;

        for j = 1:length(words)

            % find the index of the word in the unique word list

            idx = find(strcmp(words{j}, unique_words) == 1);

            if idx      % If the word is in the database, use it to calculate the probability
                n_valid_words = n_valid_words + 1;
                for k = 1:3
                    % P(Tweet | Category)
                    % Probability of "tweet" given a category (probability that word is in that catgory
%                     if unique_words{idx,k+2} ~= 0
                        probs(k) = probs(k) * unique_words{idx,k+2};
%                     end
                end
            end
        end
        
        if n_valid_words >= n_words_thresh

            tweet_prob = [probs(1) * P_category(1);...
                          probs(2) * P_category(2);...
                          probs(3) * P_category(3)];

            [max_prob, max_id] = max(tweet_prob);

            switch max_id
                case 1
                    predictions{i,2} = 'c';
                case 2
                    predictions{i,2} = 'm';
                case 3
                    predictions{i,2} = 'n';
            end
                  
        else
            predictions{i,2} = 'n';
        end
        
        predictions{i,3} = probs(1) * P_category(1);
        predictions{i,4} = probs(2) * P_category(1);
        predictions{i,5} = probs(3) * P_category(1);
                
        
        % Make the prediction P ( category | Tweet )
        % P(Category | Tweet) = P(Tweet | Category) * P(Category) / P(Tweet)
        
        
    end


    accuracy = zeros(3,2);
    critical_false = [];
    
    % Figure out the accuracy
    for i = 1:length(predictions)
        if strcmp(predictions{i,1},'c')
            if strcmp(predictions{i,2},'c')
                accuracy(1,1) = accuracy(1,1) + 1;
                predictions{i,6} = 1;
            else
                accuracy(1,2) = accuracy(1,2) + 1;
                predictions{i,6} = 0;
            end
        elseif strcmp(predictions{i,1},'m')
            if strcmp(predictions{i,2},'m')
                accuracy(2,1) = accuracy(2,1) + 1;
                predictions{i,6} = 1;
            else
                accuracy(2,2) = accuracy(2,2) + 1;
                predictions{i,6} = 0;
                if strcmp(predictions{i,2},'c')
                    critical_false = [critical_false; i];
                end
            end
        elseif strcmp(predictions{i,1},'n')
            if strcmp(predictions{i,2},'n')
                accuracy(3,1) = accuracy(3,1) + 1;
                predictions{i,6} = 1;
            else
                accuracy(3,2) = accuracy(3,2) + 1;
                predictions{i,6} = 0;
                if strcmp(predictions{i,2},'c')
                    critical_false = [critical_false; i];
                end
            end
        end
    end
    
    disp('==========================')
    disp('Prediction Accuracy: ')
    disp(['Cridical Incidents: ',num2str(accuracy(1,1)/sum(accuracy(1,:))*100),'%'])
    disp(['Minor Incidents: ',num2str(accuracy(2,1)/sum(accuracy(2,:))*100),'%'])
    disp(['Non Incidents: ',num2str(accuracy(3,1)/sum(accuracy(3,:))*100),'%'])
    disp([num2str(length(critical_false)),' falsely identified critical incidents'])
    
    
end

function count = fcount(feature, category, unique_words)

    % Find the feature in the unique words array
    a = find(strcmp(feature,unique_words) == 1);

    if a
        if strcmp(category,'c')
                count = unique_words{a,3};
        elseif strcmp(category,'m')
                count = unique_words{a,4};
        elseif strcmp(category,'n')
                count = unique_words{a,5};
        end
    else
        count = 0;
    end


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