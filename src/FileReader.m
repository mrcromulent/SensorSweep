classdef FileReader < handle
    
    properties
        % File
        filepath
        % Global
        entrySqSide
        areaDims
        numObjects
        objects
        simulationTimeLimit
        % Sensors
        sensorMaxSpeed
        sensorRange
        sensorTimeLimit
        numSensors        
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
            commentLines = cellfun(@(x)strcmp(x(1:1),"#"), tmp);
            tmp(commentLines) = [];
            x = length(tmp);
            
            numObjects = str2double(tmp(2));
            assert(length(tmp) == numObjects + 8, "Incorrect number of inputs");
            
            % 
            self.areaDims             = self.validate(1e3 * str2num(tmp{1})); %#ok<ST2NM>
            self.numObjects           = self.validate(str2double(tmp(2)));
            self.entrySqSide          = self.validate(str2double(tmp(x-5,:)));
            self.numSensors           = self.validate(str2double(tmp(x-4,:)));
            self.sensorRange          = self.validate(str2double(tmp(x-3,:)));
            self.sensorMaxSpeed       = self.validate(str2double(tmp(x-2,:)));
            self.sensorTimeLimit      = self.validate(str2double(tmp(x-1,:)));
            self.simulationTimeLimit  = self.validate(str2double(tmp(x,:)));
            
            %
            shapes = {};
            for i = 3:3+self.numObjects-1
                id = i - 2;
                shapes(id) = {self.buildShape(id, self.validate(tmp{i}))};
            end
            
            self.objects = shapes;
        end
    end
    
    methods(Static)
        function v = validate(v)
            assert(all(v >= 0), "Negative input found: " + num2str(v));
        end
        
        function sh = buildShape(id, line)
            
            shData = textscan(line, "%s", "Delimiter", " ");
            strName = shData{1}{1};
            numericPart = num2cell(cellfun(@str2double, shData{1}(2:end))');
            
            switch strName
                case "rectangle",       fu = @Rectangle;
                case "square",          fu = @Square;
                case "circle",          fu = @Circle;
            end
            
            sh = fu(id, numericPart{:});
        end
    end
    
end