local lastInput = "Mouse"

local Bind = Instance.new("BindableEvent")
local Input = {}

    Input.activePrompts = {}

    Input.correspondingInputs = {
        ["Interaction_Primary"] = {Enum.KeyCode.E,Enum.KeyCode.ButtonX},
    }

    Input.Changed = Bind.Event
    Input.currentDevice = "Mouse" --//Default

    function Input.InputFromEnum(enum)
        local function checkInDictionary(items)
            for _,data in pairs(items) do
                if data == enum then
                    return true
                end
            end
            return false
        end

        local State = Enum.UserInputType

        local isMouseUser = checkInDictionary({State.MouseButton1,State.MouseButton2,State.MouseButton3,State.MouseWheel,State.MouseMovement,State.Keyboard,State.TextInput})
        local isGamepadUser = checkInDictionary({State.Gamepad1,State.Gamepad2,State.Gamepad3,State.Gamepad4,State.Gamepad5,State.Gamepad6,State.Gamepad7,State.Gamepad8})
        if isMouseUser then
            return "Mouse"
        elseif isGamepadUser then
            return "Gamepad"
        elseif enum ~= Enum.UserInputType.Focus then --//keyboard likes to get that input for some reason ¯\_(ツ)_/¯
            return "Touch"
        else
            return Input.currentDevice
        end
    end

    function Input._getCorrespondingInput(inputItem)
        local numberedIndex = if Input.currentDevice == "Mouse" then 1 elseif Input.currentDevice == "Gamepad" then 2 else nil
        local inputEnum = Input.correspondingInputs[inputItem][numberedIndex]
        return inputEnum
    end

    function Input.Fire()
        lastInput = Input.currentDevice
        Input.currentDevice = Input.InputFromEnum(game:GetService("UserInputService"):GetLastInputType()) --//!!dont check if a certain device is enabled, input will lock up!!

        if lastInput ~= Input.currentDevice then
            Bind:Fire(Input.currentDevice,lastInput)
            -- Input._updateInputCorrespondence()
        end
    end

return Input