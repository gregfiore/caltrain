function score = compute_score(input_string, match_string, idx, score_map)

    score = 0;

    for i = 1:length(score_map.types)
        switch score_map.types{i}
            case 'Identifier'
                score = score + score_map.scores(i);
            case 'Capitalization'
                if strcmp(input_string(idx), upper(match_string(1)));
                    score = score + score_map.scores(i);
                end
            case 'Preceeding Spaces'
                if idx > 1
                    if strcmp(input_string(idx-1), ' ')
                        score = score + score_map.scores(i);
                    end
                end
            case 'Following Characters'
                if (idx + length(match_string)) > length(input_string)
                    if strfind(' ,.\;)"&', input_string(end))
                        score = score + score_map.scores(i);
                    end
                else
                    if strfind(' ,.\;)"&', input_string(idx + length(match_string)))
                        score = score + score_map.scores(i);
                    end
                end
            case 'Location'
                score = score + score_map.scores(i) * (length(input_string)-idx)/length(input_string);
            case 'Preceeding Direction'
                try 
                    if strcmpi(input_string(idx-2:idx-1),match_string(1:2))
                        score = score + score_map.scores(i);
                    elseif strcmpi(input_string(idx-3:idx-2),match_string(1:2))
                        score = score + score_map.scores(i);
                    end
                catch
                end
                
            otherwise 
                disp(['Unsupported Score Map Type: ',score_map.types{i}])
        end
    end

end