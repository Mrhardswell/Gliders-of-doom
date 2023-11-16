local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = Knit.CreateController { Name = "InterfaceController" }

local Camera = workspace.CurrentCamera
local Player = game.Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")
local Blur = Lighting:WaitForChild("Blur")

local _View = script:WaitForChild("View")
local CurrentGui = Instance.new("ObjectValue")

local LoadedViews = {}

local Keys = {
    Backpack = Enum.KeyCode.B;
}

local Start = function()
    for _, View in _View:GetChildren() do
        if View:IsA("ModuleScript") then
            local ViewModule = require(View)
            local ViewName = View.Name
            local ViewInstance = {ViewInstance = task.spawn(function()ViewModule.new(PlayerGui:WaitForChild(ViewName), Interface)end)}
            LoadedViews[ViewName] = ViewInstance
            LoadedViews[ViewName].InputConnection = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
                if GameProcessed then return end
                if Input.KeyCode == Keys[ViewName] then
                    if CurrentGui.Value then
                        Interface:CloseUI(CurrentGui.Value.Name)
                    else
                        Interface:OpenUI(ViewName)
                        CurrentGui.Value = PlayerGui:FindFirstChild(ViewName)
                    end
                end
            end)
        end
    end
end

function Interface:KnitStart()
    self.MultiplierService = Knit.GetService("MultiplierService")
    task.spawn(Start)
end

function Interface:OpenUI(Name)
    local Gui = PlayerGui:FindFirstChild(Name)
    if Gui then
        Gui.Enabled = true
        Blur.Size = 24
        Camera.FieldOfView = 50
        if CurrentGui.Value then
            CurrentGui.Value.Enabled = false
        end
        CurrentGui.Value = Gui
        print("Opening UI: " .. Name)
    else
        print("Failed open UI: " .. Name)
        return
    end
end

function Interface:CloseUI(Name)
    local Gui = PlayerGui:FindFirstChild(Name)
    if Gui then
        Gui.Enabled = false
        Camera.FieldOfView = 70
        Blur.Size = 0
        CurrentGui.Value = nil
        print("Closing UI: " .. Name)
    else
        print("Failed normaly close UI: " .. Name, "Attempting to force close...")
        Camera.FieldOfView = 70
        Blur.Size = 0
        CurrentGui.Value = nil
        return
    end
end

function Interface:ToggleUI(Name)
    assert(Name, "No name provided")
    local Gui = PlayerGui:FindFirstChild(Name)
    if Gui then
        if Gui.Enabled then
            self:CloseUI(Name)
        else
            self:OpenUI(Name)
        end
    else
        print("Failed toggle UI: " .. Name)
        return
    end
end

return Interface