local hasProperty = require(script.Parent.generic).hasProperty

return {
    saveStates = function(coreItem : Instance,savedProperties : {[number] : string},unpacked : boolean?)
        unpacked = unpacked == nil and true or false

        local savedData = {}
        if coreItem:IsA("Instance") then
			for _,itemProperty in pairs(savedProperties) do
				local success,result = hasProperty(coreItem,itemProperty)
				if success and unpacked == true then
						savedData[itemProperty] = result
				end
			end
        end

        return savedData,coreItem
    end,

    loadStates = function(coreItem : Instance,savedProperties : {[number] : string})
        for propertyname,property in pairs(savedProperties) do
            local success,_ = hasProperty(coreItem,propertyname)
            if success and coreItem:FindFirstChild(propertyname) == nil then
                coreItem[propertyname] = property
            end
        end
        return coreItem
    end,
}