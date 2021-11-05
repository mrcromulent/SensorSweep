classdef Sensor < handle
    
    properties
       id
       range
       pos
       max_speed
       spawn_time
       area_dims
       state
       sen_img
       ran_img
       sp 
    end
    
    methods
        function self = Sensor(id, range, pos, max_speed, spawn_time, area_dims)
            self.id = id;
            self.range = range;
            self.pos = pos;
            self.max_speed = max_speed;
            self.spawn_time = spawn_time;
            self.area_dims = area_dims;
            self.state = SensorStates.NotYetSpawned;
        end
        
        function activate(self)
            self.state = SensorStates.Active;
        end
        
        function destroy(self)
            self.state = SensorStates.Destroyed;
        end
        
        function move(self, dt)
            if self.state ~= SensorStates.Destroyed
                
                speed = min(self.max_speed, self.range / dt);
                
                th = 2 * pi * rand();
                self.pos = self.pos + speed * dt * [cos(th) sin(th)];
                self.constrainToSpace()
            end
        end
        
        function constrainToSpace(self)
            self.pos(1) = min(max(self.pos(1), 0), self.area_dims(1));
            self.pos(2) = min(max(self.pos(2), 0), self.area_dims(2));
        end
        
        function setspawnPoint(self, spawnPoint)
            self.sp = spawnPoint;
            self.pos = spawnPoint;
        end
        
        function drawSelf(self)
            
            x = self.pos(1);
            y = self.pos(2);
            r = self.range;
            
            if self.state == SensorStates.Destroyed
                r = 4;
                self.sen_img = rectangle("Position", [x-r y-r 2*r 2*r], "Curvature", [1, 1], "FaceColor", "r");
                self.ran_img = rectangle("Position", [x y 1 1], "Curvature", [1, 1], "EdgeColor", "r");
                
            else
                self.sen_img = rectangle("Position", [x y 1 1], "Curvature", [1, 1], "FaceColor", "r");
                self.ran_img = rectangle("Position", [(x - r) (y - r) 2 * r 2 * r], "Curvature", [1, 1], "EdgeColor", "r");
            end
            
        end
        
        function hideSelf(self)
            if self.state ~= SensorStates.Destroyed
                set(self.ran_img, "Visible", "off");
                set(self.sen_img, "Visible", "off");
            end
        end
    end
    
end