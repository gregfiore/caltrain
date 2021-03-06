% Load in the train data
fid = fopen('CaltrainStations.txt','rt');
stations = {};
n_stations = 0;
while feof(fid) == 0
    stations = [stations; fgetl(fid)];
    n_stations = n_stations + 1;
end
fclose(fid);

station_location = zeros(n_stations,2);

im = imread('Caltrain Zone Map.jpg');

a = im(55:70,230:247,3);
a(:,1:4) = 0;
a(:,16:end) = 0;
a(1:3,:) = 0;
a(14:end,:) = 0;


temp1 = im(:,1:300,1);

b = imfilter(double(temp1),double(a));


% Find the stations

mask = zeros(size(temp1));
mask(b > 5.2e6) = 1;

% im2 = im .* mask;
im2 = mask';

BW = im2bw(im2);

cc = bwconncomp(BW);

for i = 1:cc.NumObjects
    roi = cc.PixelIdxList{i};
    col = ceil(roi/cc.ImageSize(1,1));
    row = roi - (col-1)*cc.ImageSize(1,1);
    
    % compute the centroid
    cent_x = (col' * ones(length(col),1))/length(col);
    cent_y = (row' * ones(length(row),1))/length(row);
    
    station_location(i,:) = [cent_x,cent_y];
    
end

figure
imshow(im);
hold on
% plot(station_location(:,2),station_location(:,1),'kx')
set(gca,'Position',[0 0 1 1])
% xlim = [0 cc.ImageSize(2)];
% ylim = [0 cc.ImageSize(1)];
set(gcf,'Position',[633   206   414   711]);

start_station = 'San Francisco';
stop_station = 'Mountain View';

start_id = length(stations) - strmatch(start_station,stations) + 1;
stop_id = length(stations) - strmatch(stop_station,stations) + 1;


plot(station_location(start_id,2),station_location(start_id,1),'g.','MarkerSize',30)
plot(station_location(stop_id,2),station_location(stop_id,1),'r.','MarkerSize',30)

plot(station_location(start_id:stop_id,2),station_location(start_id:stop_id,1),'b','LineWidth',3)

