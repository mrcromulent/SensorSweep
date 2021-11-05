classdef Shape < handle
    
    properties
       id
       px
       py
    end
    
    methods
        function self = Shape(id, px, py)
            self.id = id;
            self.px = px;
            self.py = py;
        end
    end
end