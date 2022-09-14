local pow = math.pow
local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local PI = math.pi
local c1 = 1.70158
local c2 = c1 * 1.525
local c3 = c1 + 1
local c4 = (2 * PI) / 3
local c5 = (2 * PI) / 4.5

local bounceOut = function(x)
	local n1 = 7.5625
	local d1 = 2.75

	if x < 1 / d1 then
		return n1 * x * x
	elseif x < 2 / d1 then
		return n1 * (x - 1.5 / d1) * x + 0.75
	elseif x < 2.5 / d1 then
		return n1 * (x - 2.25 / d1) * x + 0.9375
	else 
		return n1 * (x - 2.625 / d1) * x + 0.984375
	end
end

local easingsFunctions = {
	easeInQuad = function (x)
		return x^2
	end,
	easeOutQuad = function (x)
		return 1 - (1 - x)* (1 - x)
	end,
	easeInOutQuad = function (x)
		return x < 0.5 and 2 * x * x or 1 - pow(-2 * x + 2, 2) / 2
	end,
	easeInCubic = function (x)
		return x^3
	end,
	easeOutCubic = function (x)
		return 1 - pow(1 - x, 3)
	end,
	easeInOutCubic = function (x)
		return x < 0.5 and 4 * x * x * x or 1 - pow(-2 * x + 2, 3) / 2
	end,
	easeInQuart = function (x)
		return x^4
	end,
	easeOutQuart = function (x)
		return 1 - pow(1 - x, 4)
	end,
	easeInOutQuart = function (x)
		return x < 0.5 and 8 * x * x * x * x or 1 - pow(-2 * x + 2, 4) / 2
	end,
	easeInQuint = function (x)
		return x^5
	end,
	easeOutQuint = function (x)
		return 1 - pow(1 - x, 5)
	end,
	easeInOutQuint = function (x)
		return x < 0.5 and 16 * x^5 or 1 - pow(-2 * x + 2, 5) / 2
	end,
	easeInSine = function (x)
		return 1 - cos((x * PI) / 2)
	end,
	easeOutSine = function (x)
		return sin((x * PI) / 2)
	end,
	easeInOutSine = function (x)
		return -(cos(PI * x)- 1) / 2
	end,
	easeInExpo = function (x)
		return x == 0 and 0 or pow(2, 10 * x - 10)
	end,
	easeOutExpo = function (x)
		return x == 1 and 1 or 1 - pow(2, -10 * x)
	end,
	easeInOutExpo = function (x)
		return if x == 0 then 0
			elseif x == 1 then 1
			elseif x < 0.5 then pow(2, 20 * x - 10) / 2
			else (2 - pow(2, -20 * x + 10)) / 2
	end,
	easeInCirc = function (x)
		return 1 - sqrt(1 - pow(x, 2))
	end,
	easeOutCirc = function (x)
		return sqrt(1 - pow(x - 1, 2))
	end,
	easeInOutCirc = function (x)
		return x < 0.5
			and (1 - sqrt(1 - pow(2 * x, 2))) / 2
			or (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2
	end,
	easeInBack = function (x)
		return c3 * (x ^ 3) - c1 * (x ^ 2);
	end,
	easeOutBack = function (x)
		return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2)
	end,
	easeInOutBack = function (x)
		return x < 0.5
			and (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
			or (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
	end,
	easeInElastic = function (x)
		return if x == 0 then 0
			elseif x == 1 then 1
			else -pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * c4)
	end,
	easeOutElastic = function (x)
		return if x == 0 then 0
			elseif x == 1 then 1
			else pow(2, -10 * x)* sin((x * 10 - 0.75) * c4) + 1
	end,
	easeInOutElastic = function (x)
		return if x == 0 then 0
			elseif x == 1 then 1
			elseif x < 0.5 then -(pow(2, 20 * x - 10) * sin((20 * x - 11.125) * c5)) / 2
			else (pow(2, -20 * x + 10) * sin((20 * x - 11.125) * c5)) / 2 + 1
	end,
	easeInBounce = function (x)
		return 1 - bounceOut(1 - x)
	end,
	easeOutBounce = bounceOut,
	easeInOutBounce = function (x)
		return x < 0.5
			and (1 - bounceOut(1 - 2 * x)) / 2
			or (1 + bounceOut(2 * x - 1)) / 2
	end,
}

return easingsFunctions
