if 0

    clear all; close all; loadCTdata; main_caltrain_process;

    minor_incidents = get_minor_events;
    critical_incidents = get_critical_events;

    minor_cnt = zeros(length(minor_incidents),3);
    critical_cnt = zeros(length(critical_incidents),3);

    tweet_category_count = zeros(3,1);

    Data = zeros(size(raw,1),length(critical_incidents)+length(minor_incidents));

    for i = 1:size(raw,1);

        if strcmp(raw{i,3},'c')
            tweet_category_count(1) = tweet_category_count(1) + 1;
        elseif strcmp(raw{i,3},'m')
            tweet_category_count(2) = tweet_category_count(2) + 1;
        elseif strcmp(raw{i,3},'n')
            tweet_category_count(3) = tweet_category_count(3) + 1;
        end


        t = Tweet(raw{i,2});
        t.processTweet;

        % put the counts into the Data array
        Data(i,(1:length(critical_incidents))) = t.criticalIncidents';
        Data(i,length(critical_incidents)+1:end) = t.minorIncidents';



        if strcmp(raw{i,3},'c')

            minor_cnt(t.minorIncidents > 0,1) = minor_cnt(t.minorIncidents > 0,1) + 1;
            critical_cnt(t.criticalIncidents > 0,1) = critical_cnt(t.criticalIncidents > 0,1) + 1;

            if isempty(find(t.criticalIncidents > 0))
                disp(t.remainingText)
                disp('Error, no critical incident identifiers found!')
                disp([raw{i,1},' ',daytime2str(t.timestamp)])
                if strfind(t.remainingText,'hr')
                    disp('HR Found')
                end
            end

        elseif strcmp(raw{i,3},'m')
            f_id = find(t.criticalIncidents > 0);
            if f_id
                disp(t.remainingText)
                disp('Critical event identifier(s) found in a tweet classified as minor')
                for j = 1:length(f_id)
                    disp(critical_incidents{f_id(j)})
                end
            end       


            minor_cnt(t.minorIncidents > 0,2) = minor_cnt(t.minorIncidents > 0,2) + 1;
            critical_cnt(t.criticalIncidents > 0,2) = critical_cnt(t.criticalIncidents > 0,2) + 1;
        else
            minor_cnt(t.minorIncidents > 0,3) = minor_cnt(t.minorIncidents > 0,3) + 1;
            critical_cnt(t.criticalIncidents > 0,3) = critical_cnt(t.criticalIncidents > 0,3) + 1;
        end
    end

    unique_word_cnt = [minor_cnt; critical_cnt];
    unique_words = [minor_incidents; critical_incidents];

    for i = 1:3
        unique_word_cnt(:,i) = unique_word_cnt(:,i) / tweet_category_count(i);
    end

    P_category = tweet_category_count / sum(tweet_category_count);

end

critical_thresh = [1, 2, 3];
minor_thresh = [1, 2, 3, 4, 5];

c_id = find(strcmp('c',raw(:,3))==1);
m_id = find(strcmp('m',raw(:,3))==1);
n_id = find(strcmp('n',raw(:,3))==1);

% for i = length(c_id):-1:1
%     
%     disp([raw{c_id(i),1},': ',raw{c_id(i),2}])
% end
    

c_sum = sum(Data(c_id,1:length(critical_incidents)),2);
m_sum = sum(Data(m_id,1:length(critical_incidents)),2);
n_sum = sum(Data(n_id,1:length(critical_incidents)),2);


disp('----------------------------')
disp(['Total number of critical events = ',num2str(length(c_id))])

disp('------------------------------')
disp('Events without any matches')
a = find(c_sum == 0);
for j = 1:length(a)
        disp([num2str(j),' of ',num2str(length(a)),' at ',num2str(c_id(a(j))),' : ',raw{c_id(a(j)),2}]);
end

for i = 1:length(critical_thresh)
    disp('----------------------------')
    disp(['Critical Threshold = ',num2str(critical_thresh(i))])
    disp('')
    a = find(c_sum >= critical_thresh(i));
    for j = 1:length(a)
        disp([num2str(j),' of ',num2str(length(a)),' at ',num2str(c_id(a(j))),' : ',raw{c_id(a(j)),2}]);
    end
end

disp('========= INCORRECT ==============')
disp('')
% Incorrectly found
for i = 1:length(critical_thresh)
    disp('----------------------------')
    disp(['Critical Threshold = ',num2str(critical_thresh(i))])
    disp('')
    disp('Minor:')
    a = find(m_sum >= critical_thresh(i));
    for j = 1:length(a)
        disp([num2str(j),' of ',num2str(length(a)),' at ',num2str(m_id(a(j))),' : ',raw{m_id(a(j)),2}]);
    end
    disp('Non-event')
    a = find(n_sum >= critical_thresh(i));
    for j = 1:length(a)
        disp([num2str(j),' of ',num2str(length(a)),' at ',num2str(n_id(a(j))),' : ',raw{n_id(a(j)),2}]);
    end
end


