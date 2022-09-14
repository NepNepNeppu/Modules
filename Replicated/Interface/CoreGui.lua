local Default = {"TopbarEnabled"} --//Topbar disables ability to click buttons at the top
local SetDefault = {false,Default,{0,nil}}
SetDefault.__index = SetDefault

function SetCore(Bool : boolean?,Core : {[number] : string?}?,releasedata : {any}?)
	local SetData = setmetatable({Bool,Core,releasedata},SetDefault)
    local atempts = 1+SetData[3][1]

    if atempts > 5 then 
        warn("Unable to set CoreGui to "..tostring(Bool))
        return false,SetData[3][2]
    end

    local success, result = pcall(function()
        Core = Core ~= nil and Core or Default
		game:GetService("StarterGui"):SetCore(unpack(Core, 1, #Core),Bool) --//this is fine, it'll default to "TopbarEnabled"
	end)

	if not success then
		task.wait(1)
        SetCore(Bool,Core,{atempts,result})
        return
	end

	if atempts > 1 then
        warn("CoreGui failed to be set "..tostring(atempts-1).." time(s).")
    end

	return true
end

return SetCore
