local function searchThrough(item,func)
	for _,zone in ipairs(item) do
		if zone["_details"] then
			func(zone)                    
		else
			searchThrough(zone,func)
		end
	end
end

local function findDifference(old,new)
	local Items = {}
	for _,Item in pairs(old) do
		if table.find(new,Item) == nil then
			table.insert(Items,Item)
		end 
	end
	return Items
end

local runningProximities = {}
local customProximities = {}
local Proximity = {}
Proximity.__index = Proximity

    function Proximity.new(object : BasePart,radius : number,items : {[number] : BasePart}?)
        local promptShown = Instance.new("BindableEvent")
        local promptHidden = Instance.new("BindableEvent")
        local gainedItems = Instance.new("BindableEvent")
        local lostItems = Instance.new("BindableEvent")

        local self = setmetatable({
            ["promptShown"] = promptShown.Event,
            ["promptHidden"] = promptHidden.Event,
            ["gainedItems"] = gainedItems.Event,
            ["lostItems"] = lostItems.Event,
            ["referenceInstance"] = object,
            ["radius"] = radius or 5,
            ["framerate"] = 5,
            ["isInRange"] = false,
            ["proximityInstances"] = {},
            ["_details"] = {
                ["promptShown"] = promptShown,
                ["promptHidden"] = promptHidden,
                ["gainedItems"] = gainedItems,
                ["lostItems"] = lostItems,
                ["lastNearest"] = {},
                ["currentNearest"] = {},
                ["runningWith"] = "Preset",
                ["elaspedDelta"] = 0,
            }

        },Proximity)

        if items then
            self:AddItems(items)
        end

        table.insert(runningProximities,self)

        return self
    end

    function Proximity:AddItems(items : {[number] : BasePart})
        for _,basePart in pairs(items) do
            if basePart:IsA("BasePart") and not table.find(self.proximityInstances,basePart) then
                table.insert(self.proximityInstances,basePart)
            end
        end
    end

    function Proximity:RewriteItems(items : {[number] : BasePart}) --//basically useless, but it makes it easier I guess
        self.proximityInstances = {}
        self:AddItems(items)
    end

    function Proximity:RemoveItems(items : {[number] : BasePart})
        for _,basePart in pairs(items) do
            if basePart:IsA("BasePart") then
                local t = table.find(self.proximityInstances,basePart)
                if t then
                    table.remove(self.proximityInstances,t)
                end
            end
        end
    end

    function Proximity:Pause()
        
    end

    function Proximity:Release()
        
    end

    function Proximity:UnPause()
        
    end

    function Proximity:_itemsInRange()
        local found = false

        self._details.currentNearest = {}

        for _,basepart :BasePart in pairs(self.proximityInstances) do
            if (basepart.Position - self.referenceInstance.Position).Magnitude <= self.radius then
                found = true
                table.insert(self._details.currentNearest,basepart)
            end    
        end

        local gained = findDifference(self._details.currentNearest,self._details.lastNearest)
        local lost = findDifference(self._details.lastNearest,self._details.currentNearest)

        if gained[1] then
            self._details.gainedItems:Fire(gained)
        end

        if lost[1] then
            self._details.lostItems:Fire(lost)
        end

        if found == true and self.isInRange == false then
            self.isInRange = true
            self._details.lastNearest = self._details.currentNearest
            self._details.promptShown:Fire()
        elseif found == false and self.isInRange == true then
            self.isInRange = false
            self._details.lastNearest = {}
            self._details.promptHidden:Fire()
        end
    end

    function Proximity:SetUpdateType(runnerType : "Custom" | "Preset")
        local function setRunners(wanted,remove)
            for _,_ in pairs(remove) do
                if table.find(remove,self) then
                    table.remove(remove,table.find(remove,self))  
                end
            end
            for _,_ in pairs(wanted) do
                if not table.find(wanted,self) then
                    table.insert(wanted,self)  
                end
            end
            self._details.runningWith = runnerType
        end

        if runnerType == "Custom" then
            setRunners({customProximities},{runningProximities})
        elseif runnerType == "Preset" then            
            setRunners({runningProximities},{customProximities})
        end
    end

    function Proximity:UseUpdate(deltaTime : number?) --//using deltaTime means it will run within its set framerate when fired manually
        if deltaTime and self.framerate ~= 60 then --//Still using its own preset framerate (will run slower if scheduler is also a framerate < 60)
            self._details.elaspedDelta += deltaTime
            if self._details.elaspedDelta >= 1/self.framerate then
                self._details.elaspedDelta = 0
                self:_itemsInRange()
            end  
        else
            self._details.elaspedDelta = 0
            self:_itemsInRange()
            self:SetOverlayDetection("WorldToScreen")
        end     
    end

    function Proximity:SetOverlayDetection(overlayType : "Intersected" | "Radial" | "WorldToScreen")
        if overlayType == "Intersected" then

        elseif overlayType == "WorldToScreen" and game:GetService("RunService"):IsClient() then
            -- local mouse = game.Players.LocalPlayer:GetMouse()
            -- local position = Vector2.new(mouse.X, mouse.Y)
            -- local vector, _ = workspace.CurrentCamera:WorldToScreenPoint(self.referenceInstance.Position)
            -- local screenPoint = Vector2.new(vector.X, vector.Y)

            -- print((position - screenPoint).Magnitude)
        else --// Default is Radial
            local _, onScreen = workspace.CurrentCamera:WorldToScreenPoint(self.referenceInstance)
            if onScreen then
                
            end
        end
    end

    game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        debug.profilebegin("Proximity Class")
        searchThrough(runningProximities,function(self)
            self:UseUpdate()
        end)
        debug.profileend()
    end)

return Proximity