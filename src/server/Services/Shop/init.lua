local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
local CollectionService = game:GetService("CollectionService")

local Library = ReplicatedStorage.Shared.Library

local DataTypeHandler = require(ReplicatedStorage.Shared.Modules.DataTypeHandler)
local ItemModules = {
    Gliders = require(Library.Gliders),
    Trails = require(Library.Trails)
}
local Items = require(Library.Items)

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local GameMessage = Net:RemoteEvent("GameMessage")

local ShopService = Knit.CreateService {
    Name = "ShopService";
    Client = {};
}

local DataService

function ShopService:KnitStart()
    self.Items = require(Library.Items)
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
            if InfoType == Enum.InfoType.Asset then
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

function ShopService:BuyItem(Player, ID, ItemType)
    local ItemInfo = self.Items[ItemType][1][ID]
    local leaderstats = Player:WaitForChild("leaderstats")
    local Coins = leaderstats:WaitForChild("Coins")
    local NumeralCoins = DataTypeHandler:StringToNumber(Coins.Value)
    local IsGamepass = ItemInfo.Gamepass
    local Cost = ItemInfo.Price

    local ItemData = DataService:Get(Player, ItemType)

    if ItemData then
        local ItemOwned = ItemData[ID]

        if not ItemOwned then
            if not IsGamepass then
                if NumeralCoins >= Cost then
                    local success = DataService:AddItem(Player, ID, ItemType)
                    print(success)

                    if success then
                        Coins.Value = DataTypeHandler:NumberToString(NumeralCoins - Cost)
                        local Item = self:EquipItem(Player, ID, ItemType)
                        return "Accessory", Item
                    else
                        return false
                    end
                else
                    local CoinsNeeded = Cost - NumeralCoins
                    local IDToReturn = 6

                    if CoinsNeeded <= 100 then
                        IDToReturn = 1
                    elseif CoinsNeeded <= 500 then
                        IDToReturn = 2
                    elseif CoinsNeeded <= 2000 then
                        IDToReturn = 3
                    elseif CoinsNeeded <= 5000 then
                        IDToReturn = 4
                    elseif CoinsNeeded <= 10000 then
                        IDToReturn = 5
                    else
                        IDToReturn = 6
                    end
                    print(CoinsNeeded)

                    return "DevProduct", Items.Coins[IDToReturn]
                end
            else
                if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, ItemInfo.Gamepass) then
                    local success = DataService:AddItem(Player, ID, ItemType)

                    if success then
                        local Item = self:EquipItem(Player, ID, ItemType)
                        return "Accessory", Item
                    else
                        return false
                    end
                else
                    print("Don't own gamepass")

                    return "Gamepass", ItemInfo.Gamepass
                end         
            end
        else
            local Item = self:EquipItem(Player, ID, ItemType)
            return "Accessory", Item
        end
    end
end

function ShopService.Client:BuyItem(Player, ID, ItemType)
    return self.Server:BuyItem(Player, ID, ItemType)
end

function ShopService:EquipItem(Player, ID, ItemType)
    local LastItem = ItemType == "Gliders" and  Player:WaitForChild("LastGlider") or  Player:WaitForChild("LastTrail")
    local SingularItem = ItemType == "Gliders" and "Glider" or "Trail"
    local ItemData = DataService:GetItemData(Player, ItemType)

    if ItemData[ID] then
        local Character = Player.Character
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")

        if Humanoid then
            local Item = ItemModules[ItemType][ID].Accessory:Clone()
            LastItem.Value = ID

            for _, Child in Character:GetChildren() do
                if CollectionService:HasTag(Child, SingularItem) then
                    Child:Destroy()
                end
            end

            if ItemType == "Trails" then
                Item.Handle.Transparency = 1    
            end

            Humanoid:AddAccessory(Item)

            Player[ItemType][ID].Value = true
            LastItem.Value = ID

            return Item
        end
    else
        return false
    end
end

function ShopService.Client:EquipLastItem(Player, ItemType)
    local LastItem = ItemType == "Gliders" and "LastGlider" or "LastTrail"
    local SingularItem = ItemType == "Gliders" and "Glider" or "Trail"
    local LastItemData = DataService.DataCache[Player].Data[LastItem]

    if LastItemData then
        local Character = Player.Character
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            if not ItemModules[ItemType] and not ItemModules[LastItemData] then return end
            
            local Item = ItemModules[ItemType][LastItemData].Accessory:Clone()
            Character:SetAttribute(SingularItem, LastItemData.Name)

            for _, Child in Character:GetChildren() do
                if CollectionService:HasTag(Child, SingularItem) then
                    if Item.Name == Child.Name then
                        return Child
                    end
                end
            end

            if ItemType == "Trails" then
                Item.Handle.Transparency = 1    
            end

            Humanoid:AddAccessory(Item)

            return Item
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
        local isSpin = string.match(Name, "Spin" or "Spins")

        local Amount = tonumber(string.match(Name, "%d+"))

        if IDinList and isCoin then

            local leaderstats = Player:WaitForChild("leaderstats")
            local Coins = leaderstats:WaitForChild("Coins")
            local CurrentCoins = DataTypeHandler:StringToNumber(Coins.Value)
            Coins.Value = DataTypeHandler:NumberToString(CurrentCoins + Amount)

            DataService.DataCache[Player].Data["History"][os.time()] = {
                Type = "Coins";
                Amount = Amount;
            }

            print("Purchased Coins", Amount)

        elseif isSpin then

            local Spins = Player:WaitForChild("Spins")
            Spins.Value += Amount

            DataService.DataCache[Player].Data["History"][os.time()] = {
                Type = "Spin";
                Amount = Amount;
            }

            print("Purchased Spins:", Amount)

        end

        local Message = {
            Title = "Purchased Product";
            Text = "You have purchased " .. ProductInfo.Name;
            Duration = 5;
        }

        GameMessage:FireClient(Player, Message)

    else
        warn("Failed to purchase product", ID)
    end
end)

return ShopService