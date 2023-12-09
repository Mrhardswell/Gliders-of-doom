local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local DataTypeHandler = require(ReplicatedStorage.Shared.Modules.DataTypeHandler)

local Knit = require(ReplicatedStorage.Packages.Knit)

local CoinPopup = Knit.CreateController { Name = "CoinPopupController" }

local Player = game.Players.LocalPlayer

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function CoinPopup.new(ScreenGui, Interface)
    local self = {}

    self.Coins = Player.leaderstats:WaitForChild("Coins")
    self.CoinsPopupHolder = ScreenGui:WaitForChild("CoinsPopupHolder")

    self.CoinsInt = DataTypeHandler:StringToNumber(self.Coins.Value)
    self.OldCoinsIntValue = self.CoinsInt

    self.Coins:GetPropertyChangedSignal("Value"):Connect(function()
        self.CoinsInt = DataTypeHandler:StringToNumber(self.Coins.Value)
        local coinsValue = self.CoinsInt - self.OldCoinsIntValue

        if coinsValue <= 0 then return end

        local CoinsPopupHolderClone = self.CoinsPopupHolder:Clone()
        CoinsPopupHolderClone.Parent = ScreenGui

        local CoinsText = CoinsPopupHolderClone.CoinAmount
        local CoinsTween = TweenService:Create(CoinsPopupHolderClone, tweenInfo, {Position = UDim2.fromScale(0.39, 0.05)})

        self.OldCoinsIntValue = self.CoinsInt

        CoinsPopupHolderClone.Visible = true

        CoinsText.Text = "+" .. DataTypeHandler:NumberToString(coinsValue)
        CoinsTween:Play()

        CoinsTween.Completed:Connect(function()
            CoinsPopupHolderClone:Destroy()
        end)
    end)

    return self
end

return CoinPopup