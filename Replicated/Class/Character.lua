local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Game = require(game.StarterPlayer.StarterPlayerScripts.Client.Components)
local Client = Game.Client
local Class = Game.Class

local spr = require(Class.spr)
local Control = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local Character = {}
Character.__index = Character

    function Character._self()
        local self = setmetatable({
            Control = {
                Disable = function()
                    Control:Disable()
                end,
                Enable = function()
                    Control:Enable()
                end
            },
            Character = Client.Character.self,
            PrimaryPart = Client.Character.HumanoidRootPart
        },Character)

        return self
    end

    function Character.LookAt(dampingRatio, frequency,Position : Vector3,auto : boolean?)
        local self = Character._self()
        if self.PrimaryPart == nil then return end

        local stop = Instance.new("BindableEvent")
        local link = spr.link(self.PrimaryPart)

        link.Stopped:Once(function()
            if auto == nil then return end
            spr.stop(self.PrimaryPart)
        end)
        stop.Event:Once(function()
            spr.stop(self.PrimaryPart)
        end)

        spr.target(self.PrimaryPart,dampingRatio,frequency,{CFrame = CFrame.lookAt(self.PrimaryPart.Position, Vector3.new(Position.X, self.PrimaryPart.Position.Y, Position.Z))})

        return function()
            stop:Fire()
        end
    end

return Character