local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
local CollectionService = game:GetService("CollectionService")

local DataTypeHandler = require(ReplicatedStorage.Shared.Modules.DataTypeHandler)
local GliderModule = require(script.Gliders)

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local GameMessage = Net:RemoteEvent("GameMessage")

local ShopService = Knit.CreateService {
    Name = "ShopService";
    Client = {};
}

local DataService

function ShopService:KnitStart()
    self.Items = require(script.Items)
    DataService = Knit.GetService("DataService")
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

function ShopService.Client:GetItemData(Player, Type : string, InfoType : Enum.InfoType)
    local Items = {}
    local ItemData = self.Server.Items[Type]

    if ItemData then
        for Index, Item in ItemData do
            if type(Item) == "table" then
                for i, Data in Item do
                    Items[i] = {
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


function ShopService:BuyGlider(Player, ID)
    local ItemInfo = self.Items["Gliders"][1][ID]
    local leaderstats = Player:WaitForChild("leaderstats")
    local Coins = leaderstats:WaitForChild("Coins")
    local NumeralCoins = DataTypeHandler:StringToNumber(Coins.Value)
    local Cost = ItemInfo.Price

    local GliderData = DataService:Get(Player, "Gliders")
    print(GliderData)

    if GliderData then
        local GliderOwned = GliderData[ID]
        print(GliderOwned)

        if not GliderOwned then
            if NumeralCoins >= Cost then
                local success = DataService:AddGlider(Player, ID)
                if success then
                    Coins.Value = DataTypeHandler:NumberToString(NumeralCoins - Cost)
                    local Glider = self:EquipGlider(Player, ID)
                    print("Added Glider", ID)
                    return Glider
                else
                    return false
                end
                    print("Bought and Equipped Glider", ID)
                return GliderData
                else
                    print("Not enough coins")
                return false
            end
        else
            local Data = self:EquipGlider(Player, ID)
            return Data
        end
    end

end

function ShopService.Client:BuyGlider(Player, ID)
    return self.Server:BuyGlider(Player, ID)
end

function ShopService:EquipGlider(Player, GliderId)
    local LastGlider = Player:WaitForChild("LastGlider")
    local GliderData = DataService:GetGliderData(Player)
    if GliderData[GliderId] then
        local Character = Player.Character
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            local Glider = GliderModule[GliderId].Accessory:Clone()
            LastGlider.Value = GliderId

            for _, Child in Character:GetChildren() do
                if CollectionService:HasTag(Child, "Glider") then
                    Child:Destroy()
                end
            end

            Humanoid:AddAccessory(Glider)

            Player.Gliders[GliderId].Value = true
            Player.LastGlider.Value = GliderId

            print("Equipped Glider", GliderId)
            return Glider
        end
    else
        return false
    end
end

function ShopService.Client:EquipLastGlider(Player)
    local LastGlider = DataService.DataCache[Player].Data["LastGlider"]
    print("Equipping Last Glider", LastGlider)
    if LastGlider then
        local Character = Player.Character
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            local Glider = GliderModule[LastGlider].Accessory:Clone()
            Character:SetAttribute("Glider", LastGlider.Name)

            for _, Child in Character:GetChildren() do
                if CollectionService:HasTag(Child, "Glider") then
                    if Glider.Name == Child.Name then
                        return Child
                    end
                end
            end

            Humanoid:AddAccessory(Glider)
            return Glider
        end
    else
        return false
    end
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
        local IDinList = false
        for _, Item in ShopService.Items["Coins"] do
            if Item == ID then
                IDinList = true
            end
        end

        local ProductInfo = MarketPlaceService:GetProductInfo(ID, Enum.InfoType.Product)
        local Player = game.Players:GetPlayerByUserId(PlayerID)

        local Name = ProductInfo.Name

        local isCoin = string.match(Name, "Coins")
        local Amount = tonumber(string.match(Name, "%d+"))

        if IDinList and isCoin then
            local leaderstats = Player:WaitForChild("leaderstats")
            local Coins = leaderstats:WaitForChild("Coins")
            local CurrentCoins = DataTypeHandler:StringToNumber(Coins.Value)
            Coins.Value = DataTypeHandler:NumberToString(CurrentCoins + Amount)
        end

        local Message = {
            Title = "Purchased Product";
            Text = "You have purchased " .. ProductInfo.Name;
            Duration = 5;
        }

        GameMessage:FireClient(Player, Message)
        print("Product Info", ProductInfo)
    else
        warn("Failed to purchase product", ID)
    end
end)

return ShopService