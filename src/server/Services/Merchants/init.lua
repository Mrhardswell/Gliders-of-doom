local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Net = require(game.ReplicatedStorage.Packages.Net)

local MarketplaceService = game:GetService("MarketplaceService")

local BlockMessage = Net:RemoteEvent("BlockMessage")

local DataTypeHandler = require(game.ReplicatedStorage.Shared.Modules.DataTypeHandler)

local Merchants = Knit.CreateService {
    Name = "Merchants";
    Client = {};
}

local BlockData = require(script.Data)

function Merchants:KnitStart()
    self.DataService = Knit.GetService("DataService")
end

function Merchants.RequestSell(Player, Merchant)
    local BlockInventory = Player:FindFirstChild("BlockInventory")
    if not BlockInventory then return end
    local leaderstats = Player:FindFirstChild("leaderstats")
    if not leaderstats then return end
    local Coins = leaderstats:FindFirstChild("Coins")
    if not Coins then return end

    local Validated = false

    for _, Block in BlockInventory:GetChildren() do
        for Rarity, Data in BlockData do
            if Data[Block.Name] then
                local Value = Data[Block.Name]
                if Value then
                    local Worth = Value * Block.Value
                    local CoinsValue = DataTypeHandler:StringToNumber(Coins.Value)

                    local Total = CoinsValue + Worth
                    Coins.Value = DataTypeHandler:AdaptiveNumberFormat(Total, 3)
                    Block:Destroy()

                    local Message = {
                        Title = "Sold Block";
                        Text = "You sold a " .. Block.Name .. " for " .. Worth .. if Rarity == "Common" or Rarity == "Rare" then " Coins" else " Gems";
                        Duration = 5;
                        Worth = Worth;
                        Rarity = Rarity;
                    }
                    print(Message)
                    BlockMessage:FireClient(Player, Message)
                    task.wait(0.25)
                end
            end
        end
        Validated = true
    end

    if not Validated then
        local Message = {
            Title = "No Blocks";
            Text = "You have no blocks to sell";
            Duration = 5;
        }

        BlockMessage:FireClient(Player, Message)
    end

end

local VIPID = 641890482
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
        claimReward("VIP", 50, VIPID)
    elseif Reward == "Group" then
        claimReward("Group", 100, GroupID)
    end
end

return Merchants