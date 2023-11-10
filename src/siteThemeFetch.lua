-- Itz_N3p 11/09/2023
-- Look up module for Roblox Studios themes Dark and Light

local HttpService = game:GetService("HttpService")

local DarkTheme = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/QtResources/Platform/Base/QtUI/themes/DarkTheme.json"
local LightTheme = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/QtResources/Platform/Base/QtUI/themes/LightTheme.json"

type StudioThemes = "Dark" | "Light"

local siteThemeFetch = {}

local function toRGB(color)
	local value = color
	return Color3.fromRGB(math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255))
end

local function toRGBString(color)
	local value = color
	return string.format("%g,%g,%g",math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255))
end

local function qssert(predicate, str: string)
	if not predicate then
		error(str,4)
	end
	return predicate
end

-- grabs data from URL and formats it to what is needed
function repackImport(import)
	local themeData = HttpService:JSONDecode(import)
	local core = {}
	local name = themeData.Name
	
	for _,itemData in themeData.Colors do
		for guideColor, guideData in itemData do
			core[guideColor] = {}
			for index,colorHex in guideData do
				core[guideColor][index] = Color3.fromHex(colorHex:upper():sub(1,7))
			end
		end
	end
	
	themeData = nil
	import = nil

	return core, name
end

-- freezes theme tables to ensure we dont accidently change them
function deepFreeze(colorTheme)
	table.freeze(colorTheme)
	
	for i,v in colorTheme do
		table.freeze(v)
	end
	
	return colorTheme
end

-- gather theme data
local darkTheme, lightTheme = {}, {} do
	for _,rawURL in {DarkTheme, LightTheme} do
		local _themeColors, _themeName = repackImport(HttpService:GetAsync(rawURL))

		if _themeName == "Dark" then
			darkTheme = deepFreeze(_themeColors)
		elseif _themeName == "Light" then
			lightTheme = deepFreeze(_themeColors)
		else
			warn("Unable to assign theme color "..tostring(_themeName))
		end
	end
end

-- Get theme color list
siteThemeFetch.GetTheme = function(themeName: StudioThemes)
	qssert(themeName == "Dark" or themeName == "Light", "themeName must be a valid string [Dark, Light]")
	return if themeName == "Dark" then darkTheme else lightTheme
end

-- Get Dark and Light colors from a StudioStyleGuideColor
siteThemeFetch.GetThemesColor = function(guideColor: Enum.StudioStyleGuideColor, guideModifier: Enum.StudioStyleGuideModifier?)
	qssert(guideColor.EnumType == Enum.StudioStyleGuideColor, "guideColor must be StudioStyleGuideColor")
	--qssert(guideModifier.EnumType == Enum.StudioStyleGuideModifier, "guideModifier must be StudioStyleGuideColor")
	-- verify that there is a modifier in said guideColor
	local dark, light do
		guideModifier = guideModifier or Enum.StudioStyleGuideModifier.Default
		
		for _,color in {"Dark", "Light"} do
			local themeData = siteThemeFetch.GetTheme(color)
			if themeData[guideColor.Name][guideModifier.Name] == nil then
				qssert(false, string.format("Unable to locate Modifier '%s' in %s mode", guideModifier.Name, color))
			else
				-- feels redundant in a way but I dont wanna use a table
				if color == "Dark" then
					dark = themeData[guideColor.Name][guideModifier.Name]
				else
					light = themeData[guideColor.Name][guideModifier.Name]
				end
			end
		end
	end
	
	return dark, light
end

-- Search for a certain color and get all matches from a theme
siteThemeFetch.GetAvailableColors = function(themeName: StudioThemes, lookupColor: Color3)
	qssert(typeof(lookupColor) == "Color3", "lookupColor must be a valid Color3")
	qssert(themeName == "Dark" or themeName == "Light", "themeName must be a valid string [Dark, Light]")
	
	local themeData = siteThemeFetch.GetTheme(themeName)
	local availableColors = {}
	
	for colorIndex, data in themeData do
		for modifer, color: string in data do
			if toRGBString(color) == toRGBString(lookupColor) then
				if not availableColors[colorIndex] then
					availableColors[colorIndex] = {}
				end
				
				availableColors[colorIndex][modifer] = toRGB(color)
			end
		end
	end
		
	return availableColors
end

-- Search appropriate colors from alternative theme (if lookupColor is from dark mode, isDarkModeColor should be false)
siteThemeFetch.BestFitColors = function(lookupColor: Color3, isDarkModeColor: boolean)
	qssert(typeof(lookupColor) == "Color3", "lookupColor must be a valid Color3")
	qssert(typeof(isDarkModeColor) == "boolean", "isDarkModeColor must be a boolean")

	local mainThemeMatches = siteThemeFetch.GetAvailableColors((isDarkModeColor and "Dark" or "Light"), lookupColor)
	local lookupColorMode = siteThemeFetch.GetTheme(isDarkModeColor and "Light" or "Dark")
	local matchedColors = {}
				
	for colorIndex, data in mainThemeMatches do
		for modifer, _ in data do
			if not matchedColors[colorIndex] then
				matchedColors[colorIndex] = {}
			end
						
			matchedColors[colorIndex][modifer] = lookupColorMode[colorIndex][modifer]
		end
	end
	
	return matchedColors
end

-- Expects list from either 'BestFitColors' or 'GetAvailableColors', returns list of colors
siteThemeFetch.BulkSimplifyList = function(expectedList: {})
	local newList = {}
		
	for _,data in expectedList do
		for _,color in data do
			if not table.find(newList, color) then
				table.insert(newList, color)
			end
		end
	end
			
	return newList
end

return siteThemeFetch