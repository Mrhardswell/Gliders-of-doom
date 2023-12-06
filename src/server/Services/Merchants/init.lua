local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Net = require(game.ReplicatedStorage.Packages.Net)

local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BlockMessage = Net:RemoteEvent("BlockMessage")

local GameSettings = ServerStorage.GameSettings

local DataTypeHandler = require(game.ReplicatedStorage.Shared.Modules.DataTypeHandler)

local Merchants = Knit.CreateService {
    Name = "Merchants";
    Client = {};
}

function Merchants:KnitStart()
    self.DataService = Knit.GetService("DataService")
end

function Merchants.RequestSell(Player, Merchant)
    local leaderstats = Player:FindFirstChild("leaderstats")
    if not leaderstats then return end
    local Coins = leaderstats:FindFirstChild("Coins")
    if not Coins then return end
end

local Rewards = {
    ["VIP"] = GameSettings.VIPID.Value,
    ["Group"] =  GameSettings.GroupID.Value,
}

function Merchants.Client:ClaimReward(Player, Reward)
    if not Rewards[Reward] then return end

    local rewardID = Rewards[Reward]
    local isEligible = false
    if Reward == "VIP" then
        isEligible = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, rewardID)
    elseif Reward == "Group" then
        isEligible = Player:IsInGroup(rewardID)
    end

    if isEligible then
        local CurrentData = self.Server.DataService.DataCache[Player]
        local Data = CurrentData.Data
        local LastClaimedDate = Data[Reward .. "RewardsLastClaimed"]

        if not LastClaimedDate then
            CurrentData.Data[Reward .. "RewardsLastClaimed"] = os.date("*t")
        end

        if LastClaimedDate.day then
            if LastClaimedDate.day == os.date("!*t").day then
                local Message = {
                    Title = "Already Claimed";
                    Text = "You have already claimed your " .. Reward .. " reward today";
                    Duration = 5;
                }
                BlockMessage:FireClient(Player, Message)
                return
            else
                CurrentData.Data[Reward .. "RewardsLastClaimed"] = os.date("*t")
            end
        else
            print("First Claim")
            CurrentData.Data[Reward .. "RewardsLastClaimed"] = os.date("*t")
        end

        local leaderstats = Player:FindFirstChild("leaderstats")
        
        if not leaderstats then return end

        local Coins = leaderstats:FindFirstChild("Coins")
        local CoinsNumber = DataTypeHandler:StringToNumber(Coins.Value)

        if Reward == "Group" then
            Reward.Value = DataTypeHandler:AdaptiveNumberFormat(CoinsNumber + 1000, 4)
        elseif Reward == "VIP" then
            Reward.Value = DataTypeHandler:AdaptiveNumberFormat(CoinsNumber + 4000, 4)
            
            Player.Data.WheelSpins.Value += 1
        end
    end
end

return Merchants