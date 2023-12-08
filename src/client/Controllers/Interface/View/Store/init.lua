local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Library = ReplicatedStorage.Shared.Library

local Player = game.Players.LocalPlayer

local UISounds = SoundService.UI

local Knit = require(ReplicatedStorage.Packages.Knit)

local StartingPage = "Coins"

local Store = {}

local TweenInfos = {
    Hovered = TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    Unhovered = TweenInfo.new(.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Pressed = TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
}

local RegistedProducts = {}

function Store.new(ScreenGui, Interface)
    local self = {}

    self.ShopService = Knit.GetService("ShopService")
    self.DataService = Knit.GetService("DataService")
    self.Item_Data = require(Library.Items)

    self.ScreenGui = ScreenGui
    self.Main = ScreenGui.Main
    self.Items = self.Main.Items
    self.UIPageLayout = self.Items.UIPageLayout

    self.Header = self.Main:WaitForChild("Header")
    self.Exit = self.Header:WaitForChild("Exit")
    self.ExitOriginalSize = self.Exit.Size

    self.FeaturedPage = self.Items.Featured
    self.CoinsPage = self.Items.Coins
    self.GlidersPage = self.Items.Gliders
    self.TrailsPage = self.Items.Trails

    self.ActionButtons = self.Main:WaitForChild("ActionButtons")

    self.ActiveButtons = {}
    self.GlidersData = nil
    self.TrailsData = nil

    self.ColorTargets = {
        On = {
            Outer = Color3.fromRGB(255, 221, 85),
            Inner = Color3.fromRGB(204, 175, 57),

        },
        Off = {
            Outer = Color3.fromRGB(74, 255, 149),
            Inner = Color3.fromRGB(59, 204, 115),
        }
    }

    self.ShopService:CheckGamepasses():andThen(function(Result)
        self.GamepassData = Result
    end):await()

    self.ShopService:GetItemData("Gamepass", Enum.InfoType.GamePass):andThen(function(Data)
        self.FeaturedData = Data
    end):await()

    self.ShopService:GetItemData("Coins", Enum.InfoType.Product):andThen(function(Data)
        self.CoinsData = Data
    end):await()

    self.ShopService:GetItemData("Gliders", Enum.InfoType.Asset):andThen(function(Data)
        self.GlidersData = Data
    end):await()

    self.ShopService:GetItemData("Trails", Enum.InfoType.Asset):andThen(function(Data)
        self.TrailsData = Data
    end):await()

    for _, Button in self.ActionButtons:GetChildren() do
        if Button:IsA("TextButton") then
            local Data = {}
            local TargetData = self[Button.Name.."Data"]
            
            Data.Button = Button

            Data.Template = self[Button.Name.."Page"].Template:Clone()
            self[Button.Name.."Page"].Template.Parent = nil
            Data.Template.Parent = nil
                        
            local LastTrail = Player:WaitForChild("LastTrail")
            local LastGlider = Player:WaitForChild("LastGlider")

            local function itemChanged(ItemType)
                local LastItem = ItemType == "Gliders" and LastGlider or LastTrail
                local Page = ItemType == "Gliders" and self.GlidersPage or self.TrailsPage

                for _, Item in Player[ItemType]:GetChildren() do
                    if Item.Value then
                        if Item.Name == LastItem.Value then
                            Page[Item.Name].Buy.Main.Label.Text = "Equipped"
                            Page[Item.Name].Buy.Main.BackgroundColor3 = self.ColorTargets.On.Outer
                            Page[Item.Name].Buy.Main.Inner.BackgroundColor3 = self.ColorTargets.On.Inner
                        else
                            Page[Item.Name].Buy.Main.Label.Text = "Equip"
                            Page[Item.Name].Buy.Main.BackgroundColor3 = self.ColorTargets.Off.Outer
                            Page[Item.Name].Buy.Main.Inner.BackgroundColor3 = self.ColorTargets.Off.Inner
                        end
                    end
                end
                print("Last "..ItemType.." Changed", LastItem.Value)
            end

            LastTrail.Changed:Connect(function()
                itemChanged("Trails")
            end)

            LastGlider.Changed:Connect(function()
                itemChanged("Gliders")
            end)
            
            for Index, _Data in TargetData do
                local ItemTemplate = Data.Template:Clone()

                if _Data.Type == "Trails" or _Data.Type == "Gliders" then
                    local BuyButton = ItemTemplate.Buy
                    local ViewportFrame = ItemTemplate.ViewportFrame
                    local OriginalSize = ItemTemplate.Buy.Size

                    local ItemId = _Data.ItemInfo.Name   

                    if ItemId == nil then print("ItemId is nil", _Data) continue end

                    local Item = ReplicatedStorage.Assets[_Data.Type]:FindFirstChild(ItemId)

                    if not Item then
                        warn(_Data.Type.." Not Found", ItemId)
                        continue
                    end

                    local Item_Data = self.Item_Data[_Data.Type][1][ItemId]
                    ItemTemplate.Label.Text = ItemId
                    ItemTemplate.Name = ItemId
                    ItemTemplate.LayoutOrder = Item_Data.ListLayout

                    BuyButton.Main.Label.Text = _Data.ItemInfo.Price

                    ItemTemplate.Parent = self.Items[Button.Name]

                    local Owned = Player[_Data.Type]:FindFirstChild(ItemId)

                    if Owned then
                        Owned = Owned.Value
                    end

                    local ItemModel = Instance.new("Model")
                    ItemModel.Name = ItemId
                    ItemModel.Parent = ViewportFrame

                    local ItemClone = Item:Clone()

                    for _, Part in ItemClone:GetChildren() do
                        Part.Parent = ItemModel
                        if Part:IsA("Model") then
                            for _, SubPart in Part:GetChildren() do
                                SubPart.Anchored = true
                            end
                            continue
                        end
                        Part.Anchored = true
                    end

                    ItemClone:Destroy()

                    local Camera = Instance.new("Camera")
                    Camera.CameraSubject = ItemModel
                    Camera.CameraType = Enum.CameraType.Scriptable
                    Camera.CFrame = CFrame.new(ItemModel:GetPivot().Position + Vector3.new(0, 4, -7.5), ItemModel:GetPivot().Position)

                    ViewportFrame.CurrentCamera = Camera

                    BuyButton:SetAttribute("ProductId", ItemId)

                    RegistedProducts[ItemId] = BuyButton

                    if Owned then
                        ItemTemplate.Buy.Main.Label.Text = "Equip"
                        local LastItem = _Data.Type == "Gliders" and "LastGlider" or "LastTrail"

                        if Player[LastItem].Value == ItemId then
                            ItemTemplate.Buy.Main.Label.Text = "Equipped"
                            ItemTemplate.Buy.Main.BackgroundColor3 = self.ColorTargets.On.Outer
                            ItemTemplate.Buy.Main.Inner.BackgroundColor3 = self.ColorTargets.On.Inner
                        end
                    end
                    
                    BuyButton:SetAttribute("Hovered", false)

                    local Tweens = {
                        Hovered = TweenService:Create(ItemTemplate.Buy, TweenInfos.Hovered, {
                            Size = OriginalSize + UDim2.new(0, 2, 0, 2);
                        }),
                        Unhovered = TweenService:Create(ItemTemplate.Buy, TweenInfos.Unhovered, {
                            Size = OriginalSize;
                        }),
                        Pressed = TweenService:Create(ItemTemplate.Buy, TweenInfos.Pressed, {
                            Size = OriginalSize + UDim2.new(0, -2, 0, -2);
                        }),
                    }

                    BuyButton:GetAttributeChangedSignal("Hovered"):Connect(function()
                        if BuyButton:GetAttribute("Hovered") then
                            UISounds.Hover:Play()
                            Tweens.Hovered:Play()
                        else
                            Tweens.Unhovered:Play()
                        end
                    end)

                    BuyButton.MouseEnter:Connect(function()
                        BuyButton:SetAttribute("Hovered", true)
                    end)

                    BuyButton.MouseLeave:Connect(function()
                        BuyButton:SetAttribute("Hovered", false)
                    end)

                    BuyButton.MouseButton1Click:Connect(function()
                        UISounds.Click:Play()
                        Tweens.Pressed:Play()

                        self.ShopService:BuyItem(ItemId, _Data.Type):andThen(function(DataType, BuyData)
                            if DataType == "Accessory" then
                                ItemTemplate.Buy.Main.Label.Text = "Equipped"
                                ItemTemplate.Buy.Main.BackgroundColor3 = self.ColorTargets.On.Outer
                                ItemTemplate.Buy.Main.Inner.BackgroundColor3 = self.ColorTargets.On.Inner
                            elseif DataType == "Gamepass" then
                                MarketPlaceService:PromptGamePassPurchase(Player, BuyData)
                            elseif DataType == "DevProduct" then
                                MarketPlaceService:PromptProductPurchase(Player, BuyData)
                            end     
                        end)

                        Tweens.Pressed.Completed:Wait()
                        if BuyButton:GetAttribute("Hovered") then
                            Tweens.Hovered:Play()
                        else
                            Tweens.Unhovered:Play()
                        end

                    end)

                    ItemTemplate.Parent = self.Items[Button.Name]
                    continue
                end

                local TargetType = if _Data.ItemInfo ~= nil then _Data.ItemInfo else _Data.GamepassInfo

                local DisplayName = TargetType.Name
                local Cost = TargetType.PriceInRobux or TargetType.Price
                local IconId = TargetType.IconImageAssetId
                local Icon = "rbxassetid://" .. IconId

                if Cost == nil then print("Cost is nil",TargetType) Cost = "N/A" end

                ItemTemplate.Label.Text = DisplayName
                ItemTemplate.Name = DisplayName

                ItemTemplate.Buy.Main.Label.Text = string.format("R$ %s", tostring(Cost))
                ItemTemplate.Icon.Image = Icon

                local BuyButton = ItemTemplate.Buy
                local TargetId = TargetType.TargetId
                local ProductId = TargetType.ProductId
                local Owned

                BuyButton:SetAttribute("ProductId", ProductId)
                BuyButton:SetAttribute("TargetId", TargetId)

                RegistedProducts[ProductId] = BuyButton

                if Button.Name == "Featured" then
                    Owned = MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, TargetId)
                    if Owned then
                        ItemTemplate.Buy.Main.Label.Text = "Owned"
                    end
                end

                local OriginalSize = BuyButton.Size

                local Tweens = {
                    Hovered = TweenService:Create(BuyButton, TweenInfos.Hovered, {
                        Size = OriginalSize + UDim2.new(0, 2, 0, 2);
                    }),
                    Unhovered = TweenService:Create(BuyButton, TweenInfos.Unhovered, {
                        Size = OriginalSize;
                    }),
                    Pressed = TweenService:Create(BuyButton, TweenInfos.Pressed, {
                        Size = OriginalSize + UDim2.new(0, -2, 0, -2);
                    }),
                }

                BuyButton:SetAttribute("Hovered", false)

                BuyButton:GetAttributeChangedSignal("Hovered"):Connect(function()
                    if BuyButton:GetAttribute("Hovered") then
                        UISounds.Hover:Play()
                        Tweens.Hovered:Play()
                        else
                        Tweens.Unhovered:Play()
                    end
                end)

                BuyButton.MouseEnter:Connect(function()
                    BuyButton:SetAttribute("Hovered", true)
                end)

                BuyButton.MouseLeave:Connect(function()
                    BuyButton:SetAttribute("Hovered", false)
                end)

                BuyButton.MouseButton1Click:Connect(function()
                    UISounds.Click:Play()
                    Tweens.Pressed:Play()
                    if Owned then return end
                    if Button.Name == "Featured" then
                        MarketPlaceService:PromptGamePassPurchase(Player, TargetType.TargetId)
                    elseif Button.Name == "Coins" then
                        MarketPlaceService:PromptProductPurchase(Player, ProductId)
                    end
                    Tweens.Pressed.Completed:Wait()
                    if BuyButton:GetAttribute("Hovered") then
                        Tweens.Hovered:Play()
                    else
                        Tweens.Unhovered:Play()
                    end
                end)

                ItemTemplate.Parent = self.Items:WaitForChild(Button.Name)
            end

            local function JumpTo(Name)
                for _, Data in self.ActiveButtons do
                    if Data.Button.Name == Name then
                        Data.Button.On.Visible = true
                        Data.Button.Off.Visible = false
                    else
                        Data.Button.On.Visible = false
                        Data.Button.Off.Visible = true
                    end
                end
            end

            Data.OriginalSize = Data.Button.Size

            Data.Tweens = {
                Hovered = TweenService:Create(Data.Button, TweenInfos.Hovered, {
                    Size = Data.OriginalSize + UDim2.new(0, 2, 0, 2);
                }),
                Unhovered = TweenService:Create(Data.Button, TweenInfos.Unhovered, {
                    Size = Data.OriginalSize;
                }),
                Pressed = TweenService:Create(Data.Button, TweenInfos.Pressed, {
                    Size = Data.OriginalSize + UDim2.new(0, -2, 0, -2);
                }),
            }

            Data.Button:SetAttribute("Hovered", false)

            Data.Button:GetAttributeChangedSignal("Hovered"):Connect(function()
                if Data.Button:GetAttribute("Hovered") then
                    UISounds.Hover:Play()
                    Data.Tweens.Hovered:Play()
                    else
                    Data.Tweens.Unhovered:Play()
                end
            end)

            Data.Button.MouseEnter:Connect(function()
                Data.Button:SetAttribute("Hovered", true)
            end)

            Data.Button.MouseLeave:Connect(function()
                Data.Button:SetAttribute("Hovered", false)
            end)

            Data.Button.MouseButton1Click:Connect(function()
                UISounds.Click:Play()
                Data.Tweens.Pressed:Play()

                self.UIPageLayout:JumpTo(self[Button.Name.."Page"])
                JumpTo(Data.Button.Name)

                Data.Tweens.Pressed.Completed:Wait()

                if Data.Button:GetAttribute("Hovered") then
                    Data.Tweens.Hovered:Play()
                else
                    Data.Tweens.Unhovered:Play()
                end
            end)

            self.UIPageLayout:JumpTo(self.CoinsPage)
            JumpTo(StartingPage)

            self.ActiveButtons[Button] = Data
        end
    end

    -- Exit Button
    self.ExitTweens = {
        Hovered = TweenService:Create(self.Exit, TweenInfos.Hovered, {
            Size = self.ExitOriginalSize + UDim2.new(0, 3, 0, 3);
        }),
        Unhovered = TweenService:Create(self.Exit, TweenInfos.Unhovered, {
            Size = self.ExitOriginalSize;
        }),
        Pressed = TweenService:Create(self.Exit, TweenInfos.Pressed, {
            Size = self.ExitOriginalSize + UDim2.new(0, -3, 0, -3);
        }),
    }

    self.Exit:SetAttribute("Hovered", false)

    self.ExitTweens.Pressed.Completed:Connect(function()
        self.ExitTweens.Unhovered:Play()
    end)

    self.Exit:GetAttributeChangedSignal("Hovered"):Connect(function()
        if self.Exit:GetAttribute("Hovered") then
            self.ExitTweens.Hovered:Play()
            UISounds.Hover:Play()
        else
            self.ExitTweens.Unhovered:Play()
        end
    end)

    self.Exit.MouseButton1Click:Connect(function()
        self.ExitTweens.Pressed:Play()
        UISounds.Click:Play()
        Interface:CloseUI(ScreenGui.Name)
    end)

    self.Exit.MouseEnter:Connect(function()
        self.Exit:SetAttribute("Hovered", true)
    end)

    self.Exit.MouseLeave:Connect(function()
        self.Exit:SetAttribute("Hovered", false)
    end)

    return self
end

MarketPlaceService.PromptGamePassPurchaseFinished:Connect(function(Player, ProductId, PurchaseSuccess)
    if PurchaseSuccess then
        print("Gamepass Purchase Success", ProductId)
        local isProduct = RegistedProducts[ProductId]

        if isProduct then
            print("Product is now owned", ProductId)
            RegistedProducts[ProductId].Main.Label.Text = "Owned"
        end
    else
        print("Gamepass Purchase Failed", ProductId)
    end
end)

return Store