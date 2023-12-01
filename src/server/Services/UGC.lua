local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local UGCService = Knit.CreateService {
    Name = "UGCService";
    Client = {};
}

function UGCService:KnitStart()
    self.GameSettings = ServerStorage.GameSettings
    self.UGCID = self.GameSettings.UGCID

    self.DataService = Knit.GetService("DataService")

end

function UGCService:AwardUGC(Player, UGCID)
    local Success, Message = pcall(function()
        MarketplaceService:PromptPurchase(Player, UGCID)
    end)

    if not Success then
        warn(Message)
    end

    if Success then
        self.DataService:UpdatePlayerData(Player, "UGC", UGCID)
    end

end

return UGCService