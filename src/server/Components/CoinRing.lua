local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)
local Component = require(ReplicatedStorage.Packages.Component)

local DataTypeHandler = require(ReplicatedStorage.Shared.Modules.DataTypeHandler)

local Player = Players.LocalPlayer

local CreateCoins = Net:RemoteEvent("CreateCoins")

local CoinRing = Component.new {
    Tag = "CoinRing";
}

function CoinRing:Construct()
    self.Model = self.Instance
    self.Hitbox = self.Instance.PrimaryPart
    self.Ring = self.Model.Ring
    self.CoinAmount = 50
    self.PlayerCooldowns = {}
end

function CoinRing.Start(self)
    self.Hitbox.Touched:Connect(function(Hit)
        local humanoid = Hit.Parent:FindFirstChild("Humanoid")

        if not humanoid then return end
        if humanoid.Health <= 0 then return end
        
        local character = Hit.Parent
        local player = Players:GetPlayerFromCharacter(character)

        if self.PlayerCooldowns[player.Name] and os.time() - self.PlayerCooldowns[player.Name] < 30 then return end

        self.PlayerCooldowns[player.Name] = os.time()

        local coins = player.leaderstats:WaitForChild("Coins")
        local coinsValue = DataTypeHandler:StringToNumber(coins.Value)
        local totalCoins = coinsValue + self.CoinAmount
        coins.Value = DataTypeHandler:AdaptiveNumberFormat(totalCoins, 2)
        CreateCoins:FireClient(player, self.Model)
    end)
end

return CoinRing