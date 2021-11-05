classdef FileReader < handle
    
    properties
        % File
        filepath
        % Global
        entry_sq_side
        area_dims
        num_objects
        objects
        simulation_time_limit
        % Sensors
        sensor_max_speed
        sensor_range
        sensor_time_limit
        num_sensors        
    end
    
    methods
        
        function self = FileReader(fp)
            self.filepath = fp;
            conf = fopen(self.filepath, "rt");
            
            %check if file exists. 
            if conf <= 0 
                error("File error");
            end
            
            tmp = textscan(conf, "%s", "Delimiter", "\n");
            fclose(conf);
            
            tmp = tmp{1};
            comment_lines = cellfun(@(x)strcmp(x(1:1),"#"), tmp);
            tmp(comment_lines) = [];
            x = length(tmp);
            
            num_objects = str2double(tmp(2));
            assert(length(tmp) == num_objects + 8, "Incorrect number of inputs");
            
            % 
            self.area_dims              = self.validate(1e3 * str2num(tmp{1})); %#ok<ST2NM>
            self.num_objects            = self.validate(str2double(tmp(2)));
            self.entry_sq_side          = self.validate(str2double(tmp(x-5,:)));
            self.num_sensors            = self.validate(str2double(tmp(x-4,:)));
            self.sensor_range           = self.validate(str2double(tmp(x-3,:)));
            self.sensor_max_speed       = self.validate(str2double(tmp(x-2,:)));
            self.sensor_time_limit      = self.validate(str2double(tmp(x-1,:)));
            self.simulation_time_limit  = self.validate(str2double(tmp(x,:)));
            
            %
            shapes = {};
            for i = 3:3+self.num_objects-1
                id = i - 2;
                shapes(id) = {self.build_shape(id, self.validate(tmp{i}))};
            end
            
            self.objects = shapes;
        end
    end
    
    methods(Static)
        function v = validate(v)
            assert(all(v >= 0), "Negative input found: " + num2str(v));
        end
        
        function sh = build_shape(id, line)
            
            sh_data = textscan(line, "%s", "Delimiter", " ");
            strName = sh_data{1}{1};
            numericPart = num2cell(cellfun(@str2double, sh_data{1}(2:end))');
            
            switch strName
                case "rectangle",       fu = @Rectangle;
                case "square",          fu = @Square;
                case "circle",          fu = @Circle;
            end
            
            sh = fu(id, numericPart{:});
        end
    end
    
end