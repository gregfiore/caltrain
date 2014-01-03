function [train, train_id] = find_train_no(train_no, trains)
% 
% Function:
%
% Purpose: Find and return the train by Train Number 
%
% Inputs:  Desired train number, array of train objects

train_id = 0;
train = [];

for i = 1:length(trains)
    if trains(i).number == train_no
        train_id = i;
        train = trains(i);
        break
    end
end
