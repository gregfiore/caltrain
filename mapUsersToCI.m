function CI_list = mapUsersToCI(users)

CI_list = [];

for i = 1:length(users)
    if users(i).notificationSetting(1)
        CI_list = [CI_list; users(i).userapn];
    end
end
            
        