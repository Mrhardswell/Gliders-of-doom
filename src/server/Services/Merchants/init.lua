local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Net = require(game.ReplicatedStorage.Packages.Net)

local MarketplaceService = game:GetService("MarketplaceService")

local BlockMessage = Net:RemoteEvent("BlockMessage")

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
    print("Coins: " .. Coins.Value)
end

local VIPID = 656809264
local GroupID = 33193007

function Merchants.Client:ClaimReward(Player, Reward)
    local function claimReward(rewardType, rewardAmount, rewardID)
        local isEligible = false
        if rewardType == "VIP" then
            isEligible = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, rewardID)
        elseif rewardType == "Group" then
            isEligible = Player:IsInGroup(rewardID)
        end

        if isEligible then
            local CurrentData = self.Server.DataService.DataCache[Player]
            local Data = CurrentData.Data
            local LastClaimedDate = Data[rewardType .. "RewardsLastClaimed"]

            if not LastClaimedDate then
                CurrentData.Data[rewardType .. "RewardsLastClaimed"] = os.date("*t")
            end

            if LastClaimedDate.day then
                if LastClaimedDate.day == os.date("!*t").day then
                    local Message = {
                        Title = "Already Claimed";
                        Text = "You have already claimed your " .. rewardType .. " reward today";
                        Duration = 5;
                    }
                    BlockMessage:FireClient(Player, Message)
                    return
                else
                    CurrentData.Data[rewardType .. "RewardsLastClaimed"] = os.date("*t")
                end
            else
                print("First Claim")
                CurrentData.Data[rewardType .. "RewardsLastClaimed"] = os.date("*t")
            end

            local leaderstats = Player:FindFirstChild("leaderstats")
            if not leaderstats then return end
            local Reward = leaderstats:FindFirstChild(rewardType)
            local RewardNumber = DataTypeHandler:StringToNumber(Reward.Value)
            Reward.Value = DataTypeHandler:AdaptiveNumberFormat(RewardNumber + rewardAmount, 3)
        end
    end

    if Reward == "VIP" then
        claimReward("VIP", 250, VIPID)
    elseif Reward == "Group" then
        claimReward("Group", 100, GroupID)
    end

end

return Merchants