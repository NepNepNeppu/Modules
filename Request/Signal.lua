--//Remote and Bindable Event Organizer

local RunService = game:GetService("RunService")

--initialize default data
local InitData = {}

InitData.server = false

InitData.Binded = {}
InitData.Remote = {}

local onAdded = Instance.new("BindableEvent")
local onRemoved = Instance.new("BindableEvent")

function InitData.ClientToServer(name : string)
    local formatName = "CtS"..name
end

function InitData.ServerToClient(name : string)
    local formatName = "StC"..name
end

return InitData