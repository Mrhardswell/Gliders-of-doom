local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local UI = Assets.UI

local ProgressBar = UI:WaitForChild("ProgressBar")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local HUD = PlayerGui:WaitForChild("HUD")
local ValueDisplays = HUD:WaitForChild("ValueDisplays")

local Game = Knit.CreateController { Name = "GameController" }

ProgressBar.Parent = HUD

function Game:UpdateTimer()
    local TimeLeft = ReplicatedStorage:WaitForChild("TimeLeft")
    local Time = TimeLeft.Value

    local Minutes = math.floor(Time / 60)
    local Seconds = Time % 60
    local TimeString = string.format("%02d:%02d", Minutes, Seconds)
    ValueDisplays:WaitForChild("TimeLeft").Amount.Text = TimeString
end

function Game:KnitStart()
    self.GameService = Knit.GetService("GameService")
    self.TimeLeft = ReplicatedStorage:WaitForChild("TimeLeft")

    self.TimeLeft.Changed:Connect(self.UpdateTimer)

end

return Game