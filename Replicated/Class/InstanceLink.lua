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

    function InstanceLink:AddLink(item : any,warn : boolean?)
        if self:HasLink(item) == false then
            table.insert(self.Links,item)
        elseif warn and warn == true then
            warn(string.format("Attempt to link %s to core:[%s] but it is already linked.",tostring(item),tostring(self.coreLink)))
        end
    end

    function InstanceLink:RemoveLink(item : any,warn : boolean?)
        local isLinked,Item = self:HasLink(item)
        if isLinked then
            table.remove(self.Links,table.find(self.Links,Item))
        elseif warn and warn == true then
            warn(string.format("Attempt to remove %s from core:[%s] but it does not exist.",tostring(item),tostring(self.coreLink)))
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