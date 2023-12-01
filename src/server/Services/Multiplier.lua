local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local MultiplierService = Knit.CreateService {
    Name = "MultiplierService";
    Client = {};
}

local DoubleCoinsId = 655593490

local function PlayerAdded(Player)
    local Bonuses = Instance.new("Folder")
    Bonuses.Name = "Bonuses"
    Bonuses.Parent = Player

    local CoinsMultiplier = Instance.new("BoolValue")
    CoinsMultiplier.Name = "Coins"
    CoinsMultiplier.Parent = Bonuses

    local FriendsMultiplier = Instance.new("NumberValue")
    FriendsMultiplier.Name = "Friends"
    FriendsMultiplier.Parent = Bonuses

    local function CheckForBonuses()
        local HasDoubleCoins = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, DoubleCoinsId)
        CoinsMultiplier.Value = HasDoubleCoins
    end

    CheckForBonuses()
end

function MultiplierService.Client:BuyMultiplier(Player, Type)
    if Type == "Coins" then
        MarketplaceService:PromptGamePassPurchase(Player, DoubleCoinsId)
    end
end

function MultiplierService.Client:CheckForBonuses(Player)
    local Bonuses = Player:WaitForChild("Bonuses")
    local CoinsMultiplier = Bonuses:WaitForChild("Coins")

    local HasDoubleCoins = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, DoubleCoinsId)
    CoinsMultiplier.Value = HasDoubleCoins

end

Players.PlayerAdded:Connect(function(Player)
    PlayerAdded(Player)
    for _, player in Players:GetPlayers() do
        local Friends = 0
        for _, OtherPlayer in Players:GetPlayers() do
            if OtherPlayer == player then
                continue
            end
            if player:IsFriendsWith(OtherPlayer.UserId) then
                Friends += 1
            end
        end
        Player.Bonuses.Friends.Value = Friends
    end
end)

for _, Player in Players:GetPlayers() do
    coroutine.wrap(PlayerAdded)(Player)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player, GamePassId, Purchased)
    if Purchased then
        if GamePassId == DoubleCoinsId then
            local Bonuses = Player:WaitForChild("Bonuses")
            local CoinsMultiplier = Bonuses:WaitForChild("Coins")
            CoinsMultiplier.Value = true
        end
    end
end)

return MultiplierService