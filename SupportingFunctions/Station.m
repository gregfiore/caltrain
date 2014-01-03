classdef Station < handle
    
    properties
        name = '';
        aliases = {};
        schedule = [];
        location = [0, 0];
    end
    
    methods
        function s = Station(name)
            s.name = name;
        end
        
    end
end