local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")

local Knit = require(ReplicatedStorage.Packages.Knit)

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
            Items[Index] = {
                ItemInfo = MarketPlaceService:GetProductInfo(Item, InfoType);
                Type = Type;
            }
        end
    else
        warn("Invalid Type")
    end
    return Items
end

return ShopService