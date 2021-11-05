classdef Circle < Shape
    
    properties
       r
    end
    
    methods
        function self = Circle(id, r, px, py)
            self = self@Shape(id, px, py);
            self.r = r;
        end
        
        function inRange = inSensorRange(self, sensor)
            
            inRange = false;
            d2sensor = distance(sensor.pos, [self.px, self.py]);
            
           if d2sensor <= self.r + sensor.range
              inRange = true; 
           end
        end
        
        % Returns true if point is interior to the shape
        function b = pointInterior(self, point)
            b = false;
            if distance(point, [self.px, self.py]) <= self.r
                b = true;
            end
        end
        
        function drawSelf(self, color, alpha)
            
            x = self.px - self.r;
            y = self.py - self.r;
            d = 2 * self.r;
            
           rectangle("Position", [x y d d], "Curvature", [1, 1], "FaceColor", [color, alpha]) 
        end
    end
    
end