function drawNPolygonMin1(points)
    local n = #points - 2
    for i = 1, n do
        local firstPoint = points[1]
        local secondPoint = points[i+1]
        local thirdPoint = points[i+2]
    end
end


function drawNPolygonMin2(points)
    local n = points--#points
    local layers = math.floor(math.log(n - 1, 2))
    for depth = 1, layers do
        local d2 = 2 ^ depth
        local d2m1 = 2 ^ (depth - 1)
        local numOfTriangles = math.round(points / (d2))
        for triangle = 1, numOfTriangles do
            local base = (d2 * (triangle - 1)) + 1
            local firstPoint = points[base]
            local secondPoint = points[base + d2m1]
            local thirdIndex = base + (d2m1 * 2)
            if thirdIndex > points then thirdIndex = 1 end
            local thirdPoint = points[thirdIndex]
        end
    end
end