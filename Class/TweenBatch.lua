--[[
class Tween
Description:
	Tweening Module used to manipulate one or multiple tweens at once
    Classic tweening with a new implementations
API:
	Tween = Tween.new()
		Creates a new tween object
	Tween.connections = dictionary
		Returns all connections, Ex : (tween.Completed,)
	Tween.tweens = dictionary
		Returns all tween objects
	Tween.playing = boolean
        Returns whether the tweens are playing
    Tween.speed = number [0, infinity)
        Sets the speed that the tweens transition at
	Tween.IsPropertyOf(instance, string)
        Returns if a property can be tweened in an instance
    Tween:Create(instance dictionary, tweeninfo, tween dictionary)
        Creates tween objects to been tweened
    Tween:Import(tween dictionary)
        Adds premade tweens to been tweened
    Tween:Reschedule()
        None
    Tween:Cancel()
        Cancels all tweens that are playing
    Tween:Pause()
        Pauses all tweens that are playing
    Tween:Play()
        Plays all tweens from where they left off
    Tween:Restart()
        Plays all tweens from the beginning
    Tween:Quit(string)
        Removes all tweens using the style determined by the first argument
    Tween.Completed()
        Yields current thread until all tweens are completed
    Tween:Launch(number)
        Moves all tweens up in time
]]


local TweenService = game:GetService("TweenService")

local Tween = {}
Tween.__index = Tween

    function Tween.new()
        local self = setmetatable({
            connections = {}, --//only used if the thread is paused
            tweens = {},
            playing = false,
            speed = 1,
        }, Tween)

        return self
    end

    function Tween.IsPropertyOf(tweenObject : Instance,property : string)
        local success = pcall(function()
            return tweenObject[property]
        end)
        return success
    end    

    --//is there more? I dunno you can add more if you know more
    function Tween:Create(objects : {[number] : Instance},tweenInfo : TweenInfo,tweenData : {any})
        for _,object in pairs(objects) do
            table.insert(TweenService:Create(object,tweenInfo,tweenData))
        end
    end

    function Tween:Import(tweens : {[number] : Tween})
        for _,tween in pairs(tweens) do
            table.insert(self.tweens,tween)
        end
    end

    function Tween:Reschedule()
        
    end

    function Tween:Cancel() --//Not Tween:Quit(), Tween:Quit() completely removes the tween objects
        
    end

    function Tween:Pause()
        
    end

    function Tween:Play()
        
    end

    function Tween:Quit()
        
    end

    function Tween:Completed()
        
    end

return Tween
