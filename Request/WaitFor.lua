local World = {}

    function World.isNested(request : string,preset : Instance?)
        local Format = request:split(".")
        local Class = preset or game
        for _,data in pairs(Format) do
            if Class:FindFirstChild(data) ~= nil then
                Class = Class[data]
            else
                return tostring(Class.Name) == tostring(Format[#Format]),Class
            end
        end 
        return true,Class
    end

    function World.getRandomID()
		local randomGenerator = Random.new()
		local largeNumber = randomGenerator:NextInteger(-os.time(), os.time())
		return largeNumber   
    end

    function World.waitFor(request : string,preset : Instance?)
        local Format = request:split(".")
        local Class = preset or game
        for _,data in pairs(Format) do
            if Class:FindFirstChild(data) ~= nil then
                Class = Class[data]
            else
                Class = Class:WaitForChild(data)
            end
        end
        return Class
    end

    function World.applyWithoutMass(object : BasePart)
        object.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        object.Massless = true
    end

    function World.lockedObject(item : string,name : string,Parent,update)
        if Parent:FindFirstChild(name) == nil then
            local Item = World.newObject(item,name,Parent)
            return function ()
                update(Item,false)
            end
        else
            return function ()
                return Parent:FindFirstChild(name),true
            end
        end
    end

    function World.newObject(item : string,name : string,Parent)
        local Item = Instance.new(item)
        Item.Name = name
        Item.Parent = Parent
        return Item
    end

return World