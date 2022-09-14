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

    function World.getRandomID()
		local randomGenerator = Random.new()
		local largeNumber = randomGenerator:NextInteger(-os.time(), os.time())
        if World.getRandomIdStorage == nil then
            World.getRandomIdStorage = {}
        end
        if table.find(World.getRandomIdStorage,largeNumber) then
            return World.getRandomID()
        end
        table.insert(World.getRandomIdStorage,largeNumber)
		return largeNumber   
    end

    function World.isOfItem(item : any,is : string)
        local success, result = pcall(function()
            return item[is]
        end)
        return success, result
    end

    function World.hasProperty(item : any,is : string)
        local success,result = pcall(function()
            local s,r = World.isOfItem(item,is)
            if s and not item:FindFirstChild(is) then
                return r
            end
        end)
        return success, result
    end

    function World.saveStates(coreItem : Instance,savedProperties : {[number] : string},unpacked : boolean?)
        unpacked = unpacked == nil and true or false

        local savedData = {}
        if coreItem:IsA("Instance") then
			for _,itemProperty in pairs(savedProperties) do
				local success,result = World.hasProperty(coreItem,itemProperty)
				if success then
					if unpacked == true then
						savedData[itemProperty] = result
					end
				end
			end
        end

        return savedData,coreItem
    end

    function World.loadStates(coreItem : Instance,savedProperties : {[number] : string})
        for propertyname,property in pairs(savedProperties) do
            local success,_ = World.hasProperty(coreItem,propertyname)
            if success and coreItem:FindFirstChild(propertyname) == nil then
                coreItem[propertyname] = property
            end
        end
        return coreItem
    end
    
    function World.newObject(item : string,name : string,Parent)
        local Item = Instance.new(item)
        Item.Name = name
        Item.Parent = Parent
        return Item
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

return World
