--[[EX:
    local forgeLink = InstanceLink.new(game.Workspace)
    forgeLink:AddLink("string",true) --boolean checks for duplicates and warns if true, if its blank will be false and it warn about duplicates
    forgeLink:AddLink(game.Workspace.Part)

    local retrieveLink = InstanceLink.GetLink(game.Workspace)
    retrieveLink:RemoveLink(game.Workspace.Part,true)
    retrieveLink:RemoveLink(game.Workspace.Part,true) --warn because it does not exist

    local isLinked, item = retrieveLink:HasLink("string")
    print(isLinked, item)
]]


local InstanceLink = {}
InstanceLink.__index = InstanceLink

local Links = {}

    function InstanceLink.GetLink(item)
        for _,link in pairs(Links) do
            if item == link.coreLink then
                return link
            end
        end
        warn(string.format("Link for core:[%s] does not exist.",tostring(item)))
    end

    function InstanceLink.new(instance)
        local self = setmetatable({
            coreLink = instance,
            Links = {},
        },InstanceLink)

        table.insert(Links,self)

        return self
    end

    function InstanceLink:AddLink(item : any,callback : boolean?)
        if self:HasLink(item) == false then
            table.insert(self.Links,item)
        elseif callback and callback == true then
            warn(string.format("Attempt to link %s to core:[%s] but it is already linked.",item,self.coreLink))
        end
    end

    function InstanceLink:RemoveLink(item : any,callback : boolean?)
        local isLinked,Item = self:HasLink(item)
        if isLinked then
            table.remove(self.Links,table.find(self.Links,Item))
        elseif callback and callback == true then
            warn(string.format("Attempt to remove %s from core:[%s] but it does not exist.",item,self.coreLink))
        end
    end

    function InstanceLink:HasLink(item : any)
        for _,linkedItem in pairs(self.Links) do
            if linkedItem == item then
                return true,linkedItem
            end
        end
        return false,item
    end

return InstanceLink