function d = lsdist(spx, spy, p1x, p1y, p2x, p2y)
    A = spx - p1x;
    B = spy - p1y;
    C = p2x - p1x;
    D = p2y - p1y;

    dot     = A * C + B * D;
    lenSq   = C * C + D * D;

    param = -1.0;
    if lenSq ~= 0
        param = dot / lenSq;
    end

    if param < 0
        xx = p1x;
        yy = p1y;
    elseif param > 1
        xx = p2x;
        yy = p2y;
    else
        xx = p1x + param * C;
        yy = p1y + param * D;
    end

    dx = spx - xx;
    dy = spy - yy;
    d = sqrt(dx * dx + dy * dy);
end
