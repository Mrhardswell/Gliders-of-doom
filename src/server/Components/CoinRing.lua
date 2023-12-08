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
local SFX = SoundService.SFX

local CreateCoins = Net:RemoteEvent("CreateCoins")

local CoinRing = Component.new {
    Tag = "CoinRing";
}

function CoinRing:Construct()
    self.Model = self.Instance
    self.Hitbox = self.Instance.PrimaryPart
    self.Ring = self.Model.Ring
    self.CoinAmount = 1000
    print("Constructed")
end

function CoinRing.Start(self)
    print("Started")
    local debounce = false

    self.Hitbox.Touched:Connect(function(Hit)
        if not debounce then
            print("touched")
            local humanoid = Hit.Parent:FindFirstChild("Humanoid")
            if not humanoid then return end
    
            debounce = true

            local character = Hit.Parent
            local player = Players:GetPlayerFromCharacter(character)
    
            local coins = player.leaderstats:WaitForChild("Coins")
            local coinsValue = DataTypeHandler:StringToNumber(coins.Value)
            local totalCoins = coinsValue + self.CoinAmount
            coins.Value = DataTypeHandler:AdaptiveNumberFormat(totalCoins, 2)
            CreateCoins:FireClient(player, self.Model)
            
            SFX.CoinRing:Play()

            task.wait(5)
            debounce = false
        end
    end)
end

return CoinRing