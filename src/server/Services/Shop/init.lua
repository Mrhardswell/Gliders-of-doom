local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")

local DataTypeHandler = require(ReplicatedStorage.Shared.Modules.DataTypeHandler)

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local GameMessage = Net:RemoteEvent("GameMessage")

local ShopService = Knit.CreateService {
    Name = "ShopService";
    Client = {};
}

function ShopService:KnitStart()
    self.Items = require(script.Items)
end

function ShopService.Client:CheckGamepasses(Player)
    local Gamepasses = {}
    for Index, ID in self.Server.Items["Gamepass"] do
        local HasGamepass = MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, ID)
        Gamepasses[Index] = {
            GamepassInfo = MarketPlaceService:GetProductInfo(ID);
            HasGamepass = HasGamepass;
        }
    end
    return Gamepasses
end

function ShopService.Client:GetItemData(_, Type : string, InfoType : Enum.InfoType)
    local Items = {}
    local ItemData = self.Server.Items[Type]
    if ItemData then
        for Index, Item in ItemData do
            if type(Item) == "table" then
                for _, Data in Item do
                    Items[Index] = {
                        ItemInfo = Data;
                        Type = Type;
                    }
                end
            else
                Items[Index] = {
                    ItemInfo = MarketPlaceService:GetProductInfo(Item, InfoType);
                    Type = Type;
                }
            end
        end
        return Items
    else
        warn("Invalid Type")
    end
    return Items
end

function ShopService:AwardCoins(Player, Amount)
    local leaderstats = Player:WaitForChild("leaderstats")
    local Coins = leaderstats:WaitForChild("Coins")
    local CurrentCoins = DataTypeHandler:StringToNumber(Coins.Value)
    Coins.Value = DataTypeHandler:NumberToString(CurrentCoins + Amount)
end

MarketPlaceService.PromptGamePassPurchaseFinished:Connect(function(Player, ID, Purchased)
    if Purchased then
        print("Purchased Gamepass", ID)
    else
        print("Failed to purchase gamepass", ID)
    end
end)

MarketPlaceService.PromptPurchaseFinished:Connect(function(Player, ID, Purchased)
    if Purchased then
        print("Purchased Item", ID)
    else
        print("Failed to purchase item", ID)
    end
end)

MarketPlaceService.PromptProductPurchaseFinished:Connect(function(PlayerID, ID, Purchased)
    if Purchased then
        print("Purchased Product", ID)
        local ProductInfo = MarketPlaceService:GetProductInfo(ID, Enum.InfoType.Product)
        print("Product Info", ProductInfo)
        local Player = game.Players:GetPlayerByUserId(PlayerID)
        local leaderstats = Player:WaitForChild("leaderstats")
        local Coins = leaderstats:WaitForChild("Coins")
        local Name = ProductInfo.Name
        local Amount = tonumber(string.match(Name, "%d+"))
        local CurrentCoins = DataTypeHandler:StringToNumber(Coins.Value)
        Coins.Value = DataTypeHandler:NumberToString(CurrentCoins + Amount)

        local Message = {{
            Title = "Purchased Product";
            Text = "You have purchased " .. ProductInfo.Name;
            Duration = 5;
        }}

        GameMessage:FireClient(Player, Message)

        print("Purchased Product", ID)

    else
        print("Failed to purchase product", ID)
    end
end)

return ShopService