local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local UISounds = SoundService.UI

local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Inventory = Player:WaitForChild("Inventory")

local Backpack = {}

local TweenInfos = {
    Hovered = TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    Unhovered = TweenInfo.new(.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Pressed = TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
}

function Backpack.new(ScreenGui, Interface)
    local self = {}
    self.Inventory = Player:WaitForChild("Inventory")

    self.ScreenGui = ScreenGui
    self.Main = ScreenGui.Frame:WaitForChild("Main")
    self.Container = self.Main:WaitForChild("Container")
    self.List = self.Container:WaitForChild("List")

    self.Header = self.Main:WaitForChild("Header")
    self.Exit = self.Header:WaitForChild("Exit")

    self.Template = self.List:WaitForChild("Template")
    self.Template.Parent = nil

    self.ExitOriginalSize = self.Exit.Size

    self.ExitTweens = {
        Hovered = TweenService:Create(self.Exit, TweenInfos.Hovered, {
            Size = self.ExitOriginalSize + UDim2.new(0, 3, 0, 3);
        }),
        Unhovered = TweenService:Create(self.Exit, TweenInfos.Unhovered, {
            Size = self.ExitOriginalSize;
        }),
        Pressed = TweenService:Create(self.Exit, TweenInfos.Pressed, {
            Size = self.ExitOriginalSize + UDim2.new(0, -3, 0, -3);
        }),
    }

    self.Exit:SetAttribute("Hovered", false)

    self.ExitTweens.Pressed.Completed:Connect(function()
        self.ExitTweens.Unhovered:Play()
    end)

    self.Exit:GetAttributeChangedSignal("Hovered"):Connect(function()
        if self.Exit:GetAttribute("Hovered") then
            self.ExitTweens.Hovered:Play()
            UISounds.Hover:Play()
        else
            self.ExitTweens.Unhovered:Play()
        end
    end)

    self.Exit.MouseButton1Click:Connect(function()
        self.ExitTweens.Pressed:Play()
        UISounds.Click:Play()
        Interface:CloseUI(ScreenGui.Name)
    end)

    self.Exit.MouseEnter:Connect(function()
        self.Exit:SetAttribute("Hovered", true)
    end)

    self.Exit.MouseLeave:Connect(function()
        self.Exit:SetAttribute("Hovered", false)
    end)

    self.Items = {}

    local function CreateItem(Item)
        local ItemTemplate = self.Template:Clone()
        ItemTemplate.Name = Item.Name
        ItemTemplate.Info.Text = Item.Name
        ItemTemplate.Label.Text = if Item.Value then "Equipped" else ""
        ItemTemplate.Parent = self.List
        return ItemTemplate
    end

    for _, Item in Inventory:GetChildren() do
        self.Items[Item.Name] = {
            Item = CreateItem(Item),
            Data = Item
        }
    end

    return self
end

return Backpack