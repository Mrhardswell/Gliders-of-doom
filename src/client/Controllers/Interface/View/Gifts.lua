local Gifts = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Player = game.Players.LocalPlayer
local TotalPlaytime = Player:WaitForChild("TotalPlaytime")

local Knit = require(ReplicatedStorage.Packages.Knit)

local UISounds = SoundService.UI

local Rewards = require(ReplicatedStorage.Shared.Rewards)

local HUD = Player.PlayerGui.HUD
local GiftsFrame = HUD:WaitForChild("Gifts")
local Label = GiftsFrame:FindFirstChild("Label", true)

local Interval = 1
local Current = 0

local TweenInfos = {
    Hovered = TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    Unhovered = TweenInfo.new(.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Pressed = TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
}

local NextReward = 1

function Gifts.new(ScreenGui, Interface)
    local self = {}
    self.RewardService = Knit.GetService("RewardService")

    self.ScreenGui = ScreenGui
    self.Main = ScreenGui.Frame:WaitForChild("Main")
    self.Container = self.Main:WaitForChild("Container")
    self.List = self.Container:WaitForChild("List")

    self.Header = self.Main:WaitForChild("Header")
    self.Exit = self.Header:WaitForChild("Exit")

    self.Template = self.List:WaitForChild("Template")
    self.Template.Parent = nil

    self.Rewards = {}
    self.Connections = {}

    self.PlayerData = nil

    self.RewardService:GetData():andThen(function(Data)
        self.PlayerData = Data
        print("Got player data", Data)
    end)

    repeat task.wait()
    until self.PlayerData

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

    for Index, RewardData in Rewards do
        local Reward = {}
        Reward.Button = self.Template:Clone()
        Reward.Button.Name = Index
        Reward.Button.LayoutOrder = Index

        Reward.Frame = Reward.Button:WaitForChild("Frame")
        Reward.Icon = Reward.Button:WaitForChild("Icon")
        Reward.Info = Reward.Button:WaitForChild("Info")
        Reward.TimeLeft = Reward.Button:WaitForChild("TimeLeft")

        Reward.Type = RewardData.Type
        Reward.TimeRequired = RewardData.RequiredTime
        Reward.ImageID = RewardData.ImageID
        Reward.Amount = RewardData.Amount

        Reward.Claimed = self.PlayerData.ClaimedRewards[Index] or false

        Reward.Icon.Image = Reward.ImageID
        Reward.Info.Text = string.format("+ %s %s", Reward.Amount, Reward.Type)

        Reward.OriginalSize = Reward.Icon.Size



        Reward.Button:SetAttribute("Hovered", false)

        Reward.Tweens = {
            Hovered = TweenService:Create(Reward.Icon, TweenInfos.Hovered, {
                Size = Reward.OriginalSize + UDim2.new(0, 5, 0, 5);
            }),

            Unhovered = TweenService:Create(Reward.Icon, TweenInfos.Unhovered, {
                Size = Reward.OriginalSize;
            }),

            Pressed = TweenService:Create(Reward.Icon, TweenInfos.Pressed, {
                Size = Reward.OriginalSize + UDim2.new(0, -5, 0, -5);
            }),
        }

        Reward.Button.Parent = self.List
        self.Rewards[Index] = Reward
    end

    

    self.UpdateRewards = function()
        local Playtime = TotalPlaytime.Value
        for Index, Reward in self.Rewards do
            if Playtime >= Reward.TimeRequired then
                if Reward.Claimed then
                    Reward.TimeLeft.Text = "Claimed"
                    Reward.Frame.Visible = true

                    if self.Connections[Index] then
                        for _, Connection in self.Connections[Index] do
                            Connection:Disconnect()
                        end
                        self.Connections[Index] = nil
                    end

                else

                    Reward.TimeLeft.Text = "Claim"
                    Reward.Frame.Visible = false

                    if self.Connections[Index] then
                        continue
                    end

                    self.Connections[Index] = {}

                    self.Connections[Index]["Pressed"] = Reward.Button.MouseButton1Click:Connect(function()
                        Reward.Tweens.Pressed:Play()
                        UISounds.Sold:Play()
                        Reward.Claimed = true
                        Reward.TimeLeft.Text = "Claimed"
                        Reward.Frame.Visible = true
                        self.RewardService:ClaimReward(Index)
                        self.Connections[Index]["Pressed"]:Disconnect()
                    end)

                    Reward.Tweens.Pressed.Completed:Connect(function()
                        Reward.Tweens.Unhovered:Play()
                    end)

                    self.Connections[Index]["Hovered"] = Reward.Button.MouseEnter:Connect(function()
                        Reward.Button:SetAttribute("Hovered", true)
                    end)

                    self.Connections[Index]["Unhovered"] = Reward.Button.MouseLeave:Connect(function()
                        Reward.Button:SetAttribute("Hovered", false)
                    end)

                    self.Connections[Index]["AttributeChanged"] = Reward.Button:GetAttributeChangedSignal("Hovered"):Connect(function()
                        if Reward.Button:GetAttribute("Hovered") then
                            Reward.Tweens.Hovered:Play()
                            UISounds.Hover:Play()
                        else
                            Reward.Tweens.Unhovered:Play()
                        end
                    end)

                end

            else
                Reward.TimeLeft.Text = string.format("%s" , os.date("!%X", Reward.TimeRequired - Playtime))
                Reward.Frame.Visible = true
            end
        end

        local NextRewardText = self.Rewards[NextReward].TimeLeft.Text
        if NextRewardText == "Claimed" then
            NextReward = NextReward + 1
            NextRewardText = self.Rewards[NextReward].TimeLeft.Text
        end



        Label.Text = string.format("GIFT IN %s", NextRewardText)

    end

    self.Timer = RunService.Heartbeat:Connect(function(DeltaTime)
        Current = Current + DeltaTime
        if Current >= Interval then
            Current = 0
            self.UpdateRewards()
        end
    end)

    return self
end

return Gifts