local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Mobile = {}

local LastInput = nil

local function ToggleUI(ScreenGui)
    LastInput = UserInputService:GetLastInputType()
    ScreenGui.Enabled = LastInput == Enum.UserInputType.Touch
end

function Mobile.new(ScreenGui, Interface)
    local self = {}

    self.ScreenGui = ScreenGui
    self.Main = ScreenGui.Main
    self.Controls = self.Main.Controls

    self.Buttons = {}

    for _, Button in self.Controls:GetChildren() do
        if Button:IsA("ImageButton") then
            self.Buttons[Button.Name] = {
                Button = Button;
                Tweens = {}
            }
        end
    end

    -- Connections 
    for Name, _Button in self.Buttons do
        local Button = _Button.Button

        Button.MouseButton1Down:Connect(function()
            Button:SetAttribute("Pressed", true)
        end)

        Button.MouseButton1Up:Connect(function()
            Button:SetAttribute("Pressed", false)
        end)

    end

    UserInputService.LastInputTypeChanged:Connect(function()
        ToggleUI(ScreenGui)
    end)

    ToggleUI(ScreenGui)

    return self
end

return Mobile