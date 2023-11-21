local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Data = require(script.Data)

local Net = require(game.ReplicatedStorage.Packages.Net)

local Triggered = Net:RemoteEvent("PromptTriggered")

local Merchant = Knit.Component.new {
    Tag = "Merchant";
}

function Merchant:Construct()
    self.Model = self.Instance
    self.ProxymityPrompt = Instance.new("ProximityPrompt", self.Model)
    self.Type = self.Model:GetAttribute("Type")

end

function Merchant.Start(self)
    repeat task.wait() until Knit.Started
    local Merchants = Knit.GetService("Merchants")

    local _Data = Data[self.Type]

    if not _Data then
        warn("Merchant type not found")
        return
    end

    self.ProxymityPrompt.ActionText = Data[self.Type].ActionText
    self.ProxymityPrompt.RequiresLineOfSight = false
    self.ProxymityPrompt.HoldDuration = 0.5

    self.ProxymityPrompt.Triggered:Connect(function(Player)
        if self.Type == "Sell" then
            Merchants.RequestSell(Player, self)
        end
        if self.Type == "VIP" or "Group" then
            Triggered:FireClient(Player, self.Type, self.Model)
        end
    end)

end

return Merchant