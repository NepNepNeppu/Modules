local GetLighting = game.ReplicatedStorage.Event.Data.Lighting

local Config = require(game.ReplicatedStorage.Configurations.MainConfig)

local Components = {}

    Components.convertToRGB = function(r : number,g : number,b : number)
        local ra,ga,ba = math.floor((r*255)+0.5),math.floor((g*255)+0.5),math.floor((b*255)+0.5)
        return ra,ga,ba
    end

    Components.lerp = function(a,b,c : number)
        if typeof(a) == "Color3" then
            local r,g,b = a.R + (b.R - a.R) * c,a.G + (b.G - a.G) * c,a.B + (b.B - a.B) * c
            return Color3.new(r,g,b)
        else
            return a + (b - a) * c
        end
    end

    Components.FindInOrder = function(find,Dictionary)
        for _,TableValue in pairs(Dictionary) do
            if tostring(TableValue[1]) == tostring(find) then
                return TableValue
            end
        end
    end

    Components.OrderInArray = function(Dictionary)
        local lenth = 0
        local Array = {}
        for _,v in pairs(Dictionary) do        
            lenth+=1
            Array[lenth] = v
        end
        return Array
    end

    if game:GetService("RunService"):IsClient() then
        Components.DayLight,Components.LockTime = GetLighting:InvokeServer(Config.DayCycleSettings.NightTime)
    end

return Components
