function [NBtrains, SBtrains] = mapUsersToTrains(NBtrains, SBtrains, u)
%
% Function mapUsersToTrains
% Purpose:  assign users to notify for each train

n_users = length(u);

for i = 1:n_users
    
    if u(i).notificationSetting(2)
    
        for j = 1:length(u(i).trains)

            for k = 1:length(NBtrains)

                if NBtrains(k).number == u(i).trains(j)
                    
                    NBtrains(k).users = [NBtrains(k).users; u(i).userapn];
                    
                    break
                    
                end
            end
            
            for k = 1:length(SBtrains)
                
                if SBtrains(k).number == u(i).trains(j)
                    
                    SBtrains(k).users = [SBtrains(k).users; u(i).userapn];
                    
                    break
                end
            end
        end
    end
end