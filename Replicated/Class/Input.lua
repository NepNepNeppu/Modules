local UserInputService = game:GetService("UserInputService")

local types = {"Began","Changed","Ended"}
local acceptedEnums = {Enum.KeyCode,Enum.UserInputType}

local Input = {}
Input.__index = Input

    function Input.new(inputObject : TextButton | ImageButton?)
        local Began,Changed,Ended = Instance.new("BindableEvent"),Instance.new("BindableEvent"),Instance.new("BindableEvent")

        local self = setmetatable({
            Began = Began.Event,
            Changed = Changed.Event,
            Ended = Ended.Event,

            _details = {
                began = {},
                changed = {},
                ended = {},
            },
            _binds = {
                began = Began,
                changed = Changed,
                ended = Ended,
            },
            _connections = {
                began = "static",
                changed = "static",
                ended = "static",
            }
        },Input)

        self:_initializeNewSetup(inputObject)

        return self
    end

        function Input._hasInput(inputDetect)
        for _,inputType in pairs(types) do
            if inputDetect == inputType then
                return inputDetect
            end
        end
        -- warn(string.format("%s is not a supported input type",inputDetect))
        return nil
    end

    function Input._acceptedEnumType(enum)
        for _,enumData in pairs(acceptedEnums) do
            if enumData == enum.EnumType then
                return true
            end
        end
        return false
    end

    function Input:GetInputEnums(inputDetect : "Began" | "Changed" | "Ended"?)
        local enums = {}

        local function add(inputType)         
            for _,enum in pairs(inputType) do
                table.insert(enums,enum)
            end
        end

        if inputDetect then
            add(self._details[string.lower(inputDetect)])
        else
            for _,input in pairs(self._details) do
                add(input)
            end
        end
        return enums
    end

    function Input:_initializeNewSetup(inputObject)
        for _,inputType in pairs(types) do
            local inputObject = inputObject or UserInputService
            self._connections[string.lower(inputType)] = inputObject["Input"..inputType]:Connect(function(input, gameProcessedEvent)
                for _,enum in pairs(self:GetInputEnums()) do
                    if enum == input.KeyCode or enum == input.UserInputType then
                        self._binds[string.lower(inputType)]:Fire(enum,gameProcessedEvent)
                    end
                end
            end)
        end
    end

    function Input:Disconnect(inputDetect : "Began" | "Changed" | "Ended"?)
        inputDetect = Input._hasInput(inputDetect)

        if inputDetect then
            self._connections[string.lower(inputDetect)]:Disconnect()
            self._binds[string.lower(inputDetect)]:Destroy()
        else
            for _,input in pairs(types) do
                self._connections[string.lower(input)]:Disconnect()
                self._binds[string.lower(input)]:Destroy()
            end
        end

        self:ClearInputs(inputDetect)
    end

    function Input:ClearEnum(inputDetect : "Began" | "Changed" | "Ended"?,inputs : {[number] : EnumItem})
        inputDetect = Input._hasInput(inputDetect)

        local function searchInputType(inputType,enum)
            if self._details[inputType][enum] then
                self._details[inputType][enum] = nil
            end
        end

        if inputDetect then
            for _,enum in pairs(inputs) do
                searchInputType(inputDetect,enum)
            end
        else
            for _,input in pairs(types) do
                for _,enum in pairs(inputs) do
                    searchInputType(input,enum)
                end
            end
        end
    end

    function Input:ClearInputs(inputDetect : "Began" | "Changed" | "Ended"?)
        inputDetect = Input._hasInput(inputDetect)

        if inputDetect then
            self._details[string.lower(inputDetect)] = {}
        else
            for _,input in pairs(types) do
                self._details[string.lower(input)] = {}
            end
        end
    end

    function Input:Connect(inputDetect : "Began" | "Changed" | "Ended"?,inputs : {[number] : EnumItem})
        inputDetect = Input._hasInput(inputDetect)
        
        local function addToInputType(inputType)
            for _,nextEnum in pairs(inputs) do
                if Input._acceptedEnumType(nextEnum) then
                    table.insert(self._details[string.lower(inputType)],nextEnum)
                end
            end
        end

        if inputDetect then
            addToInputType(inputDetect)
        else
            for _,input in pairs(types) do
                addToInputType(input)
            end
        end
    end

return Input