local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local MultiplierService = Knit.CreateService {
    Name = "MultiplierService";
    Client = {};
}

local DoubleCoinsId = 641865619
local DoubleGemsId = 641706765

local function PlayerAdded(Player)
    local Bonuses = Instance.new("Folder")
    Bonuses.Name = "Bonuses"
    Bonuses.Parent = Player

    local CoinsMultiplier = Instance.new("BoolValue")
    CoinsMultiplier.Name = "Coins"
    CoinsMultiplier.Parent = Bonuses

    local GemsMultiplier = Instance.new("BoolValue")
    GemsMultiplier.Name = "Gems"
    GemsMultiplier.Parent = Bonuses

    local function CheckForBonuses()
        local HasDoubleCoins = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, DoubleCoinsId)
        local HasDoubleGems = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, DoubleGemsId)

        CoinsMultiplier.Value = HasDoubleCoins
        GemsMultiplier.Value = HasDoubleGems
    end

    CheckForBonuses()
end

function MultiplierService.Client:BuyMultiplier(Player, Type)
    if Type == "Coins" then
        MarketplaceService:PromptGamePassPurchase(Player, DoubleCoinsId)
    elseif Type == "Gems" then
        MarketplaceService:PromptGamePassPurchase(Player, DoubleGemsId)
    end
end

function MultiplierService.Client:CheckForBonuses(Player)
    local Bonuses = Player:WaitForChild("Bonuses")
    local CoinsMultiplier = Bonuses:WaitForChild("Coins")
    local GemsMultiplier = Bonuses:WaitForChild("Gems")

    local HasDoubleCoins = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, DoubleCoinsId)
    local HasDoubleGems = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, DoubleGemsId)

    CoinsMultiplier.Value = HasDoubleCoins
    GemsMultiplier.Value = HasDoubleGems
end

Players.PlayerAdded:Connect(PlayerAdded)

for _, Player in Players:GetPlayers() do
    coroutine.wrap(PlayerAdded)(Player)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player, GamePassId, Purchased)
    if Purchased then
        if GamePassId == DoubleCoinsId then
            local Bonuses = Player:WaitForChild("Bonuses")
            local CoinsMultiplier = Bonuses:WaitForChild("Coins")
            CoinsMultiplier.Value = true
        elseif GamePassId == DoubleGemsId then
            local Bonuses = Player:WaitForChild("Bonuses")
            local GemsMultiplier = Bonuses:WaitForChild("Gems")
            GemsMultiplier.Value = true
        end
    end
end)

return MultiplierService