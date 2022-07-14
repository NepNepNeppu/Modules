--[[
class Object
Description:
	Fire a function anytime a property selected changes
    One Object can have one or multiple property functions

API:
	Object = Object.new(Instance,string?)
		Creates a new object collector
		{
			identification = strin
			assignedInstance = Instance,
			Properties = dictionary,
			Connections = dictionary,
			isrunning = boolean,
            OnAdded = RBXScriptConnection,
            OnRemoved = RBXScriptConnection,
			Object = methods
		}
    Object:RemoveProperties(dictionary)
        Removes any currently running or static property functions
		{
			dictionary
		}
    Object:AddProperties(dictionary)
        Adds and initalizes new properties
		{
			dictionary
		}
	Object:OnEvent(string)
		Connection storage meant to store RBXScriptConnections for Object using the name [string]
		{
			add = function,
			Disconnect = function
		}
	Object:GetPackage(string)
		Get dictionary of RBXScriptConnections from Object with the name [string]
		{
			new = function,
			Disconnect = method,
			dictionary
		}
    Object:ManualUpdate(dictionary)
        Manually update property functions
		{
			dictionary
		}
	Object:Restore(Instance)
		Restores all traits of the object in the DataModel and in the Object
    Object:Pause()
        Pause all active running properties
    Object:UnPause()
        Resume all paused properties
	Object:Quit(string?)
		Removes all Connections and Properties

Usage :

local Handler = Property.new(game.Workspace.Restoration,"CustomName")

Handler:AddProperties {
	Size = function()
		print(Handler.assignedInstance.Size)
	end,
	Position = function()
		print(Handler.assignedInstance.Position)
	end,
}

Handler:OnEvent "PartChanged" {
	Handler.OnRemoved:Connect(function()
		Handler:Quit()
	end),
}

]]

--[[TODO:
    Rewrite "Changed" to be reliable and as a method
    add custom error messages
]]

local CollectionService = game:GetService("CollectionService")

function hasProperty(object : Instance,property : string)
	local success = pcall(function()
		return object[property]
	end)
	return success
end

function getTable(properties : {any})
    local newTable = {}

    local function loopThrough(addedNew,newIndex : string?)
        for index,value in pairs(addedNew) do
            if typeof(value) == "table" then
                loopThrough(value,newIndex)
            elseif typeof(value) ~= "table" then
                newTable[newIndex or index] = value
            end
        end
    end

    loopThrough(properties)

    return newTable
end

function PropertyInit(self,properties : {any},kick : string?) --kick is a string OR a function
    if typeof(properties) ~= "table" then return end

	local function checkAndApply(newProperty : string,fire)       
		if (hasProperty(self.assignedInstance,newProperty) and self.Properties[newProperty] == nil) or kick == true then
        	self.Properties[newProperty] = {fire,kick}
		end
	end

	local directory = if properties then properties elseif self.Properties then self.Properties  else {}
	for propertyAll,fire in pairs(directory) do
		task.spawn(checkAndApply,propertyAll,fire)
	end
end

function GetPackageData(shadowSelf,PackageName)
	local orderSelf = {}

	function orderSelf:Disconnect()
		for _,connect in pairs(shadowSelf.Connections[PackageName]) do
			connect:Disconnect()
		end
	end

	function orderSelf.new(data)
		for i,func in pairs(data) do
			i = tostring(if typeof(i) == "Instance" then i.Name else i)
			local function check()
				if func == nil then
					warn("Must Disconnect")
					return false
				elseif shadowSelf.Connections[PackageName][i] ~= nil then
					warn("Must Disconnect "..tostring(i).." to override the current Connection")
					return false
				else 
					return true
				end
			end
			local continue = check()
			if continue and (typeof(func) == "RBXScriptConnection" or type(func) == "function") then
				shadowSelf.Connections[PackageName][i] = func
			elseif continue then
				warn('Item "'..i..'" in package "'..tostring(PackageName)..'" must be a RBXScriptConnection')
			end
		end
		return shadowSelf.Connections[PackageName]
	end

	return orderSelf,shadowSelf.Connections[PackageName]
end

local Object = {}
Object.__index = Object

    Object.Contents = {}

	function Object.new(Label : Instance,name : string?)
		if Object.Contents[name or Label] then return Object.Contents[name or Label] end
        if Label == nil or typeof(Label) ~= "Instance" then return end

		Object.Contents[name or Label] = "loading"

		local OnRemoved = Instance.new("BindableEvent")
		local OnAdded = Instance.new("BindableEvent")

		local function getId()
			local randomGenerator = Random.new()
			local largeNumber = randomGenerator:NextInteger(-os.time(), os.time())
			return "_PropertyHandler#"..tostring(largeNumber)
		end

		local self = setmetatable({
			identification = getId(),
			assignedInstance = Label,
			isrunning = true,
			Properties = {},
			Connections = {},
            ["OnAdded"] = OnAdded.Event,
            ["OnRemoved"] = OnRemoved.Event,
			__data = { --//Intended to be used by the methods
                Runner = {Difference = {}},
				wasrunning = true,
				name = name or nil,
			}
		}, Object)

        self.__data.Runner.Stepped = game:GetService("RunService").Stepped:Connect(function()
			if self.isrunning == false then return end
			for property,data in pairs(self.Properties) do
				local success = hasProperty(self.assignedInstance,property)

				if success then
					local fire,kick = data[1],data[2]    
					if type(fire) ~= "function" then
						self.Properties[property] = nil
						self.__data.Runner.Difference[property] = nil
						warn('"'..property..'" was removed from '..self.assignedInstance.Name..". "..property.." must be a function")
					else
						--forceful update
						if kick ~= nil then
							if type(kick) == "string" then --preassigned function, so its just a manual kick
								fire()
							elseif type(kick) == "function" then --manual function, reverts to previous function if assigned
								fire()
								self.Properties[property] = {kick,nil}
							end
						--rewrite this to be reliable
						elseif self.assignedInstance[property] ~= self.__data.Runner.Difference[property]  then
							if self.__data.Runner.Difference[property] == nil then
								self.__data.Runner.Difference[property] = self.assignedInstance[property]
							else
								self.__data.Runner.Difference[property] = self.assignedInstance[property]
								fire()
							end
						end
					end
				elseif not success then
					self.Properties[property] = nil
					self.__data.Runner.Difference[property] = nil
					warn('"'..property..'" was removed from '..self.assignedInstance.Name..". "..property.." is not a valid property")
				end
			end
		end)

		CollectionService:AddTag(Label,self.identification)

		CollectionService:GetInstanceRemovedSignal(self.identification):Connect(function(object)
			self.wasrunning = self.isrunning
			self.isrunning = false
			self.assignedInstance = nil 
			OnRemoved:Fire(object)
		end)

		CollectionService:GetInstanceAddedSignal(self.identification):Connect(function(object)
			self.isrunning = self.__data.wasrunning
			self.wasrunning = false			
			OnAdded:Fire(object)
		end)

        Object.Contents[name or Label] = self

		return self
	end

	function Object:AddProperties(properties : {any})
        if typeof(properties) ~= "table" then return end

        local removeList = {}
		for propertyAll,fire in pairs(getTable(properties)) do
            if hasProperty(self.assignedInstance,propertyAll) then
                if self.Properties[propertyAll] and self.assignedInstance then
					warn('Cannot add "'..propertyAll..'" for "'..self.assignedInstance.Name..'"'.." because it is already running")	
				else
				    PropertyInit(self,{[propertyAll] = fire})
                    removeList[propertyAll] = fire
			    end
            end
		end

        return removeList
	end

	function Object:RemoveProperties(properties : {any})
        if typeof(properties) ~= "table" then
			properties = self.Properties
		else
			properties = getTable(properties)
		end

        local restoreList = {}
		for propertyAll,fire in pairs(properties) do
			if self.Properties[propertyAll] then
				self.Properties[propertyAll] = nil
				if hasProperty(self.assignedInstance,propertyAll) then --//incase its it invalid property
					restoreList[propertyAll] = fire
				end
			elseif self.assignedInstance then
				warn('Cannot remove "'..tostring(propertyAll)..'" form "'..self.assignedInstance.Name..'"'.." because it doesn't exist")
			end
		end

        return restoreList
	end

	function Object:OnEvent(packageName : Instance | string)
		local PackageName : string = tostring(if typeof(packageName) == "Instance" then packageName.Name else packageName)

		if self.Connections[PackageName] then
			return self:GetPackage(PackageName)
		else
		if PackageName == nil or type(PackageName) ~= "string" or PackageName:gsub(" ","") == "" or self.Connections[PackageName] ~= nil then
				warn('Package "'..tostring(PackageName)..'" must have a unique name')
				return {}
			else
                self.Connections[PackageName] = {}
				local Package = GetPackageData(self,PackageName)

				return function (data)
					Package.new(data)
                    return Package
				end
			end
		end
	end

	function Object:GetPackage(packageName : Instance | string)
		local PackageName : string = tostring(if typeof(packageName) == "Instance" then packageName.Name else packageName)
		if self.Connections[PackageName] then			
			return GetPackageData(self,PackageName)
		else
			warn('Package "'..tostring(PackageName)..'" is not a package')
		end
	end

	function Object:ManualUpdate(properties : {any})
        if typeof(properties) ~= "table" then return end

		local removeList = {}
		for propertyAll,fire in pairs(getTable(properties)) do
			if hasProperty(self.assignedInstance,propertyAll) then
				--already assigned property, so it just gets activated
				if self.Properties[propertyAll] and fire == nil and type(self.Properties[propertyAll][1]) == "function" then
				    PropertyInit(self,{[propertyAll] = self.Properties[propertyAll][1]},"PreAssigned")
                    removeList[propertyAll] = self.Properties[propertyAll][1]
				--custom function, stores previous function if there is one
				else
					local custom = self.Properties[propertyAll] and self.Properties[propertyAll][1] or nil
					PropertyInit(self,{[propertyAll] = fire},custom)
					removeList[propertyAll] = fire				
				end
			else
				warn('"'..tostring(propertyAll)..'" is not a property of '..self.assignedInstance)	
			end
		end

		return removeList
	end

	function Object:Restore(previouslyRemoved,Parent : Instance?)
        if not previouslyRemoved then
            warn("Cannot restore Object because it is nil")
        elseif self.assignedInstance ~= nil then
            warn("Cannot restore because Object is not nil") 
        elseif typeof(previouslyRemoved) ~= "Instance" then
            warn("Object restoration must be an Instance")
        else
            local restoration = previouslyRemoved:Clone()
		    local parent = typeof(Parent) == "Instance"  and Parent or previouslyRemoved.Parent
            if previouslyRemoved.Parent == nil then
			    if restoration then
				    restoration:Destroy()
			    end
            else
                restoration.Parent = parent
                CollectionService:AddTag(restoration,self.identification)
                self.assignedInstance = restoration
                Object.Contents[self.__data.name or restoration] = self
            end
        end
    end

	function Object:Pause()
		if not self.assignedInstance then return end
		self.isrunning = false
	end

	function Object:UnPause()
        if not self.assignedInstance then return end
		self.isrunning = true
	end

	function Object:Quit(single :  "Connections" | "Properties" | nil)
		if single == "Connections" then
			for packages,_ in pairs(self.Connections) do
				GetPackageData(self,packages):Disconnect()
			end
		elseif single == "Properties" then
			self:RemoveProperties()
		else
			self:Quit("Connections")
			self:Quit("Properties")
		end
	end

return Object
