return function (request)
    local Format = request:split(".")
    local World = game 
    for _,data in pairs(Format) do
        if World:FindFirstChild(data) ~= nil then
            World = World[data]
        else
            World = World:WaitForChild(data)
        end
    end
    return World
end