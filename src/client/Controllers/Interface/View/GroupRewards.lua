
local GroupRewards = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local Player = game.Players.LocalPlayer

local GroupID = 33193007

local TweenInfos = {
    Hovered = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    Unhovered = TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Pressed = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
}

function GroupRewards.new(ScreenGui, Interface)
    local self = {}

    self.Merchants = Knit.GetService("Merchants")

    self.ScreenGui = ScreenGui
    self.Main = ScreenGui:WaitForChild("Main")
    self.Button = self.Main.Container.Frame:WaitForChild("Button")
    self.OriginalSize = self.Button.Size

    self.Header = self.Main:WaitForChild("Header")
    self.Exit = self.Header:WaitForChild("Exit")

    self.ExitOriginalSize = self.Exit.Size
    self.Button:SetAttribute("Hovered", false)

    self.Tweens = {

        Hovered = TweenService:Create(self.Button, TweenInfos.Hovered, {
            Size = self.OriginalSize + UDim2.new(0, 8, 0, 8)
        }),

        Unhovered = TweenService:Create(self.Button, TweenInfos.Unhovered, {
            Size = self.OriginalSize
        }),

        Pressed = TweenService:Create(self.Button, TweenInfos.Pressed, {
            Size = self.OriginalSize - UDim2.new(0, 5, 0, 5)
        }),

        Exit = {

            Hovered = TweenService:Create(self.Exit, TweenInfos.Hovered, {
                Size = self.ExitOriginalSize + UDim2.new(0, 3, 0, 3)
            }),

            Unhovered = TweenService:Create(self.Exit, TweenInfos.Unhovered, {
                Size = self.ExitOriginalSize
            }),

            Pressed = TweenService:Create(self.Exit, TweenInfos.Pressed, {
                Size = self.ExitOriginalSize - UDim2.new(0, 3, 0, 3)
            })

        }
    
    }

    local function CheckInGroup()
        local isMember = Player:IsInGroup(GroupID)
        if isMember then
            self.Button.Label.Text = "CLAIM"
            self.Button.ImageColor3 = Color3.fromRGB(255, 255, 255)
        else
            self.Button.Label.Text = "JOIN GROUP"
            self.Button.ImageColor3 = Color3.fromRGB(255, 0, 0)
        end
    end

    Net:Connect("PromptTriggered", CheckInGroup)

    -- Button Events
    self.Button.MouseButton1Click:Connect(function()
        self.Tweens.Pressed:Play()
        local isMember = Player:IsInGroup(GroupID)
        if isMember then
            self.Merchants:ClaimReward("Group")
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Group Rewards";
                Text = "You must join the group to claim daily rewards!";
                Duration = 5;
            })
        end

        self.Tweens.Pressed.Completed:Wait()

        if self.Button:GetAttribute("Hovered") then
            self.Tweens.Hovered:Play()
        else
            self.Tweens.Unhovered:Play()
        end
    end)

    self.Button.MouseEnter:Connect(function()
        self.Button:SetAttribute("Hovered", true)
    end)

    self.Button.MouseLeave:Connect(function()
        self.Button:SetAttribute("Hovered", false)
    end)

    self.Button:GetAttributeChangedSignal("Hovered"):Connect(function()
        if self.Button:GetAttribute("Hovered") then
            self.Tweens.Hovered:Play()
        else
            self.Tweens.Unhovered:Play()
        end
    end)

     -- Exit Events
     self.Exit.MouseButton1Click:Connect(function()
        self.Tweens.Exit.Pressed:Play()
        Interface:CloseUI(ScreenGui.Name)
        self.Tweens.Exit.Pressed.Completed:Wait()

        if self.Exit:GetAttribute("Hovered") then
            self.Tweens.Exit.Hovered:Play()
        else
            self.Tweens.Exit.Unhovered:Play()
        end
    end)

    self.Exit.MouseEnter:Connect(function()
        self.Exit:SetAttribute("Hovered", true)
    end)

    self.Exit.MouseLeave:Connect(function()
        self.Exit:SetAttribute("Hovered", false)
    end)

    self.Button:GetAttributeChangedSignal("Hovered"):Connect(function()
        if self.Exit:GetAttribute("Hovered") then
            self.Tweens.Exit.Hovered:Play()
        else
            self.Tweens.Exit.Unhovered:Play()
        end
    end)

    return self
end

return GroupRewards