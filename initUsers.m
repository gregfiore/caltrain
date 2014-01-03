function u = initUsers()

load UserDB.mat

for i = 1:length(u)
    u(i).updateTrains;
%     u(i).dispUser;
end