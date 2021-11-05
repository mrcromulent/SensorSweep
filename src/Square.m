classdef Square < Rectangle
    
    properties
       s
    end
    
    methods
        function self = Square(id, s, px, py)
            self    = self@Rectangle(id, s, s, px, py);  
            self.s  = s;
        end
    end
    
end