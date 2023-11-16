local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Rewards = require(Shared.Rewards)
local DataTypeHandler = require(Shared.Modules.DataTypeHandler)

local Knit = require(ReplicatedStorage.Packages.Knit)

local RewardService = Knit.CreateService {
    Name = "RewardService";
    Client = {};
}

function RewardService:KnitStart()
    self.DataService = Knit.GetService("DataService")
end

function RewardService.Client:ClaimReward(Player, Index)
    local RewardInfo = Rewards[Index]
    if not RewardInfo then return end

    local TotalPlaytime = Player:WaitForChild("TotalPlaytime")

    if TotalPlaytime.Value >= RewardInfo.RequiredTime then

        local PlayerData = self.Server.DataService.DataCache[Player]
        if not PlayerData then return end

        local ClaimedRewards = PlayerData.Data.ClaimedRewards
        if ClaimedRewards[Index] then return end

        ClaimedRewards[Index] = true

        local RewardType = RewardInfo.Type
        local RewardAmount = RewardInfo.Amount

        local leaderstats = Player:WaitForChild("leaderstats")

        if RewardType == "Coins" then
            print(string.format("Gave %s coins to %s", tostring(RewardAmount), Player.Name))
            local Coins = leaderstats:WaitForChild("Coins")
            local CoinsValue = DataTypeHandler:StringToNumber(Coins.Value)
            local Total = CoinsValue + RewardAmount
            Coins.Value = DataTypeHandler:AdaptiveNumberFormat(Total, 2)

        elseif RewardType == "Gems" then
            print(string.format("Gave %s gems to %s", tostring(RewardAmount), Player.Name))
            local Gems = leaderstats:WaitForChild("Gems")
            local GemsValue = DataTypeHandler:StringToNumber(Gems.Value)
            local Total = GemsValue + RewardAmount
            Gems.Value = DataTypeHandler:AdaptiveNumberFormat(Total, 2)

        elseif RewardType == "GoldenPickaxe" then
            print(string.format("Gave %s golden pickaxes to %s", tostring(RewardAmount), Player.Name))
        end

    else
        print("Not enough playtime and this shouln't be possible")
    end
end

function RewardService.Client:GetData(Player)
    local PlayerData = self.Server.DataService.DataCache[Player]
    if not PlayerData then
        print("Couldn't get player data")
        return
    end
    return PlayerData.Data
end

return RewardService