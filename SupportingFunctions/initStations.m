function Stations = initStations()

    % Load in the train data
    fid = fopen('CaltrainStations.txt','rt');
    stations = {};
    n_stations = 0;
    while feof(fid) == 0
        stations = [stations; fgetl(fid)];
        n_stations = n_stations + 1;
    end
    fclose(fid);

%     disp('Successfully loaded the Caltrain Stations')

    for i = 1:n_stations
        Stations(i,1) = Station(stations{i});
        Stations(i,1).aliases = getAliases(stations{i});
    end

end


function aliases = getAliases(station_name)

    station_aliases{1,1} = {'Gilroy'};
    station_aliases{2,1} = {'San Martin','sanmartin'};
    station_aliases{3,1} = {'Morgan Hill','morganhill'};
    station_aliases{4,1} = {'Blossom Hill','blossomhill'};
    station_aliases{5,1} = {'Capitol'};
    station_aliases{6,1} = {'Tamien'};
    station_aliases{7,1} = {'San Jose','sanjose','SJ','SJD','diridon'};
    station_aliases{8,1} = {'College Park','CP','collegepark'};
    station_aliases{9,1} = {'Santa Clara','santaclara','scl'};
    station_aliases{10,1} = {'Lawrence','law'};
    station_aliases{11,1} = {'Sunnyvale','Svl','sv'};
    station_aliases{12,1} = {'Mountain View','MV','Mt View','Mtn View','MtView','mtv','mtnview','mountainview'};
    station_aliases{13,1} = {'San Antonio','SA','san ant','sanantonio'};
    station_aliases{14,1} = {'California Ave','Cal Ave','CalAve','californiaave'};
    station_aliases{15,1} = {'Palo Alto','PA','university','paloalto'};
    station_aliases{16,1} = {'Menlo Park','MP','Menlo'};
    station_aliases{17,1} = {'Redwood City','RC','RWC','redwood'};
    station_aliases{18,1} = {'San Carlos','SC','SNC','SCar','SCarlos','sancarlos'};
    station_aliases{19,1} = {'Belmont'};
    station_aliases{20,1} = {'Hillsdale','HD'};
    station_aliases{21,1} = {'Hayward Park','HP','haywardpark','hayyard'};
    station_aliases{22,1} = {'San Mateo','SMateo','SM','sanmateo'};
    station_aliases{23,1} = {'Burlingame','bvrlingame','bgame','brlngame'};
    station_aliases{24,1} = {'Millbrae','MB','Milbrae','millbrea','mil'};
    station_aliases{25,1} = {'San Bruno','sanbruno'};
    station_aliases{26,1} = {'South San Francisco','So. San Francisco'};
    station_aliases{27,1} = {'Bayshore'};
    station_aliases{28,1} = {'22nd Street','22nd'};
    station_aliases{29,1} = {'San Francisco','SF',' King','4th'}; 

    aliases = {};

    for i = 1:length(station_aliases)
        if strcmp(station_name,station_aliases{i,1}{1})
            aliases = station_aliases{i,1};
            break
        end
    end
    
end
