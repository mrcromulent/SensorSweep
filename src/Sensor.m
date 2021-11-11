classdef Sensor < handle
    
    properties
       id
       range
       pos
       maxSpeed
       spawnTime
       areaDims
       state
       senImg
       ranImg
       sp 
    end
    
    methods
        function self = Sensor(id, range, pos, maxSpeed, spawnTime, areaDims)
            self.id = id;
            self.range = range;
            self.pos = pos;
            self.maxSpeed = maxSpeed;
            self.spawnTime = spawnTime;
            self.areaDims = areaDims;
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
                
                speed = min(self.maxSpeed, self.range / dt);
                
                th = 2 * pi * rand();
                self.pos = self.pos + speed * dt * [cos(th) sin(th)];
                self.constrainToSpace()
            end
        end
        
        function constrainToSpace(self)
            self.pos(1) = min(max(self.pos(1), 0), self.areaDims(1));
            self.pos(2) = min(max(self.pos(2), 0), self.areaDims(2));
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
                self.senImg = rectangle("Position", [x-r y-r 2*r 2*r], "Curvature", [1, 1], "FaceColor", "r");
                self.ranImg = rectangle("Position", [x y 1 1], "Curvature", [1, 1], "EdgeColor", "r");
                
            else
                self.senImg = rectangle("Position", [x y 1 1], "Curvature", [1, 1], "FaceColor", "r");
                self.ranImg = rectangle("Position", [(x - r) (y - r) 2 * r 2 * r], "Curvature", [1, 1], "EdgeColor", "r");
            end
            
        end
        
        function hideSelf(self)
            if self.state ~= SensorStates.Destroyed
                set(self.ranImg, "Visible", "off");
                set(self.senImg, "Visible", "off");
            end
        end
    end
    
end