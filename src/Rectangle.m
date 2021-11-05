classdef Rectangle < Shape
    
    properties
        sx
        sy
        sides
        xl
        xr
        yl
        yu
    end
    
    methods
        function self = Rectangle(name, sx, sy, px, py)
            self        = self@Shape(name, px, py);
            self.sx     = sx;
            self.sy     = sy;
            self.sides  = self.mapSides();
        end
        
        function sds = mapSides(self)
            
            self.xl = self.px - 0.5 * self.sx;
            self.xr = self.px + 0.5 * self.sx;
            self.yl = self.py - self.sy;
            self.yu = self.py + self.sy;
            
            sds         = {};
            sds(1, :)   = {[self.xl, self.yu], [self.xr, self.yu]}; % Top
            sds(2, :)   = {[self.xl, self.yu], [self.xl, self.yl]}; % Left side
            sds(3, :)   = {[self.xr, self.yu], [self.xr, self.yl]}; % Right side
            sds(4, :)   = {[self.xl, self.yl], [self.xr, self.yl]}; % Bottom
            

            
        end
                
        function inRange = inSensorRange(self, sensor)
            inRange = false;
            
            sr = sensor.range;
            sp = sensor.pos;
            
            for i = 1:length(self.sides)
                p1 = self.sides{i, 1};
                p2 = self.sides{i, 2};
                d = lsdist(sp(1), sp(2), p1(1), p1(2), p2(1), p2(2));
                
                if d <= sr
                    inRange = true;
                    break;
                end
                
            end
        end
        
        % Returns true if point is interior to the shape
        function b = pointInterior(self, point)
            b = false;
            if (self.xl <= point(1)) && (point(1) <= self.xr) && (self.yl <= point(2)) && (point(2) <= self.yu)
                b = true;
            end
        end
        
        function drawSelf(self, color, alpha)
            x = self.px - 0.5 * self.sx;
            y = self.py - 0.5 * self.sy;
            rectangle("Position", [x, y, self.sx, self.sy], "FaceColor", [color, alpha]);
        end
        
    end
    
end