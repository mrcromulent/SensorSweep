classdef Simulation < handle
    
    properties
        fr
        dt
        currTime
        shapesFound
        pauseTime
        sensors
    end
    
    methods
        function self = Simulation(fp, realTime)
            self.fr = FileReader(fp);
            
            self.currTime = 0.0;
            
            
            if realTime
               self.dt = 1;
               self.pauseTime = self.dt;
            else
                self.dt = 5.0;
                self.pauseTime = 0.0;
            end
            
            self.shapesFound = {};
            self.makeSensors();
        end
        
        function run(self)
            self.showBackground();
            self.showShapes(self.fr.objects, [0,0,1], 0.1);
            
            while self.currTime < self.fr.simulation_time_limit
                self.currTime = self.currTime + self.dt;
                
                self.hideSensors();
                self.activateSensors();
                self.checkForCollisions();
                self.showSensors();
                self.moveSensors();
                self.reportFindings();
                drawnow;
                pause(self.pauseTime);
                
                if self.allSensorsDestroyed()
                    break;
                end
                
                
                if self.allObjectsFound() && self.fr.num_objects > 0
                    disp("All objects found!");
                    break;
                end
            end     
        end
        
        function reportFindings(self)
            for i=1:length(self.fr.objects)
                currObj = self.fr.objects{i};
                for j=1:length(self.sensors)
                    currSns = self.sensors(j);
                    if currObj.inSensorRange(currSns)
                        if ~self.shapeAlreadyFound(currObj)
                            fprintf("Shape: %i found by sensor %i \n", currObj.id, currSns.id);
                            self.addShape(currObj);
                        end
                    end
                end
            end
        end
        
        function addShape(self, shape)
            self.shapesFound{end + 1} = shape;
        end
        
        function allDestroyed = allSensorsDestroyed(self)   
            allDestroyed = true;
            
            for i = 1:length(self.sensors)
                currSensor = self.sensors(i);
                if currSensor.state ~= SensorStates.Destroyed
                    allDestroyed = false;
                    break;
                end
           end
        end

        function activateSensors(self)           
            for i = 1:length(self.sensors)
                currSensor = self.sensors(i);
                if currSensor.state == SensorStates.NotYetSpawned && self.currTime >= currSensor.spawn_time
                    currSensor.activate();
                end
           end
        end
        
        function checkForCollisions(self)           
            for i = 1:length(self.sensors)
                for j = 1:length(self.fr.objects)
                    currObj = self.fr.objects{j};
                    currSensor = self.sensors(i);
                    if currSensor.state ~= SensorStates.Destroyed && currObj.pointInterior(currSensor.pos)
                        fprintf("Sensor %i destroyed! \n", currSensor.id);
                        currSensor.destroy();
                    end
                end
           end
        end
        
        function moveSensors(self)           
            for i = 1:length(self.sensors)
              self.sensors(i).move(self.dt); 
           end
        end
        
        function alreadyFound = shapeAlreadyFound(self, shape)
            foundIds        = cellfun(@(c) c.id, self.shapesFound);
            alreadyFound    = isempty(setdiff(shape.id, foundIds));
        end
        
        function allFound = allObjectsFound(self)
            
            foundIds    = cellfun(@(c) c.id, self.shapesFound);
            allIds      = cellfun(@(c) c.id, self.fr.objects);
            allFound    = isempty(setdiff(allIds, foundIds));
        end
        
        function showSensors(self)
            for i = 1:length(self.sensors)
                currSensor = self.sensors(i);
                if self.currTime >= currSensor.spawn_time
                    currSensor.drawSelf(); 
                end
            end
        end
        
        function hideSensors(self)
           for i = 1:length(self.sensors)
              self.sensors(i).hideSelf(); 
           end
        end
        
        function makeSensors(self)
            
            sns = [];
            [spawnx, spawny, spawnTimes] = self.getSpawnInfo();
            
            for i = 1:self.fr.num_sensors
                sns = [sns, Sensor(i, self.fr.sensor_range, ...
                    [spawnx(i), spawny(i)], self.fr.sensor_max_speed, ...
                    spawnTimes(i), self.fr.area_dims)];
            end
            
            self.sensors = sns;
        end
        
        function [spawnx, spawny, spawnTimes] = getSpawnInfo(self)
            
            saw = self.fr.area_dims(1);
            sah = self.fr.area_dims(2);
            eas = self.fr.entry_sq_side;
            
            spawnx      = saw / 2 - eas / 2 + (eas) * rand(self.fr.num_sensors, 1);
            spawny      = sah / 2 - eas / 2 + (eas) * rand(self.fr.num_sensors, 1);
            spawnTimes  = (self.fr.sensor_time_limit) * rand(self.fr.num_sensors, 1);
        end
        
        function showBackground(self)
            
            ad = self.fr.area_dims;
            s = self.fr.entry_sq_side;
            w = ad(1);
            l = ad(2);
            
            rectangle("Position", [0 0 w l], "LineWidth", 2);
            rectangle("Position", [(w/2 - s/2) (l/2 - s/2) s s], "LineStyle", ":");
            
            axis equal;
            axis([0 self.fr.area_dims(1) 0 self.fr.area_dims(2)])
            set(gcf, "Units", "Normalized", "OuterPosition", [0 0 0.5 0.5]);
        end
        
        function showResults(self)
            
            clf;
            self.showBackground();
            self.showShapes(self.shapesFound, [0, 0, 1], 1.0);
            self.showShapes(self.getNotFoundShapes(), [1, 0, 0], 1.0);
            dim = [.2 .5 .3 .3];
            annotation("textbox", dim, "String", "Shapes Found in blue", "FitBoxToText", "on");
        end
        
        function notFoundShapes = getNotFoundShapes(self)
            
            notFoundShapes = {};
            for k=1:length(self.fr.objects)
                currObj = self.fr.objects{k};
                if ~self.shapeAlreadyFound(currObj)
                    notFoundShapes{end+1} = currObj;
                end
            end
            
        end
    end
    
    methods(Static)
        function showShapes(shapes, color, alpha)
            for k=1:length(shapes)
                currObj = shapes{k};
                currObj.drawSelf(color, alpha);
            end
        end
    end
    
end