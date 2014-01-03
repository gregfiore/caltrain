clear all; close all; loadCTdata; 

Data = cell(size(raw,1),4);

% raw{1241,2} = raw{1241,2}(1:70);

Data(:,1:3) = raw(:,1:3);

for i = 1:size(raw,1)

%     if strcmp(raw{i,2}(1),'"')
%         raw{i,2} = raw{i,2}(2:end-1);
%         Data{i,2} = raw{i,2};
%     end    
    try
    t = Tweet(raw{i,2});
    catch
        a = 1;
    end
    if ~ischar(t.timestamp)
%         temp_date = datenum([raw{i,1},'-2011 00:00:00']);
        temp_date = datenum([raw{i,1}(1:end-2),'20',raw{i,1}(end-1:end)],2);

        temp_date = temp_date + t.timestamp;
        Data{i,4} = temp_date;
    else
        temp_date = 0;
    end
    
    if length(Data{i,4}) > 1
        a = 1;
    end
    
end

