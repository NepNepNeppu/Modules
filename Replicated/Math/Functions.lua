local Functions = {}

    function Functions.roundNearestMultiple(x, mult)
	    return math.round(x / mult) * mult
    end

    function Functions.truncateTo(x, to)
        return x-x%to
    end

    function Functions.cframeToOrientation(CFrame)
        local _, _, _, m00, m01, m02, _, _, m12, _, _, m22 = CFrame:GetComponents()

        local X = math.atan2(-m12, m22)
        local Y = math.asin(m02)
        local Z = math.atan2(-m01, m00)

        return X,Y,Z
    end

    function Functions.smoothStep(edge0,edge1,x)
		x = (x - edge0) / (edge1 - edge0)

		return x * x * x * (x * (x * 6 - 15) + 10);
    end

    function Functions.lerp(a,b,c)
        return a + (b-a) * c
    end

	function Functions.largestNumber(...)
		local list = {...}
		table.sort(list, function(a,b)
			return a > b
		end)
		return list[1]
	end


--[[
local function castFromScreenPoint(input,measureBy)
	local function getWorldPostion()
		local ws,wr = World.hasProperty(hoverOver.Adornee,"WorldPosition") 
		local ps,pr = World.hasProperty(hoverOver.Adornee,"Position") 
		return if ws then wr elseif ps then pr else Vector3.new(0,0,0)
	end

	local vector, _ = game.Workspace.CurrentCamera:WorldToViewportPoint(getWorldPostion())
	if measureBy == "FixedScreen" then --//will have a locked radius on the screen
		local view = game.Workspace.CurrentCamera.ViewportSize
		local pX,pY = math.clamp(vector.X/view.X,0,1),math.clamp(vector.Y/view.Y,0,1)
		local iX,iY = math.clamp(input.Position.X/view.X,0,1),math.clamp(input.Position.Y/view.Y,0,1)
		return (Vector2.new(pX,pY) - Vector2.new(iX,iY)).Magnitude
	elseif measureBy == "Fixed" then --//basically the same as fixedscreen, just in "3d" space
		local inputToScreen = game.Workspace.CurrentCamera:ScreenPointToRay(input.Position.X, input.Position.Y, 1)
		local worldToScreen = game.Workspace.CurrentCamera:ScreenPointToRay(vector.X, vector.Y, 1)
		return (inputToScreen.Origin - worldToScreen.Origin).Magnitude
	else --meausure by range
		local camDistance = (game.Workspace.CurrentCamera.CFrame.Position - getWorldPostion()).Magnitude
		return castFromScreenPoint(input,"FixedScreen")*camDistance/10
	end
end]]

return Functions