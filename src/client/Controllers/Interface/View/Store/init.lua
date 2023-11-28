local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

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

    self.ScreenGui = ScreenGui
    self.Main = ScreenGui.Main
    self.Items = self.Main.Items
    self.UIPageLayout = self.Items.UIPageLayout

    self.Header = self.Main:WaitForChild("Header")
    self.Exit = self.Header:WaitForChild("Exit")
    self.ExitOriginalSize = self.Exit.Size

    self.FeaturedPage = self.Items.Featured
    self.CoinPage = self.Items.Coins
    self.GliderPage = self.Items.Gliders

    self.ActionButtons = self.Main:WaitForChild("ActionButtons")

    self.ActiveButtons = {}
    self.GliderData = nil

    self.DataService:Get("Gliders"):andThen(function(Data)
        self.GliderData = Data
    end)

    self.ShopService:CheckGamepasses():andThen(function(Result)
        self.GamepassData = Result
    end):await()

    self.ShopService:GetItemData("Gamepass", Enum.InfoType.GamePass):andThen(function(Data)
        self.FeaturedData = Data
    end):await()

    self.ShopService:GetItemData("Coins", Enum.InfoType.Product):andThen(function(Data)
        self.CoinData = Data
    end):await()

    self.ShopService:GetItemData("Gliders", Enum.InfoType.Asset):andThen(function(Data)
        self.GliderData = Data
    end):await()

    for _, Button in self.ActionButtons:GetChildren() do
        if Button:IsA("TextButton") then
            local Data = {}
            local TargetData

            if Button.Name == "Featured" then
                TargetData = self.FeaturedData
            elseif Button.Name == "Coins" then
                TargetData = self.CoinData
            elseif Button.Name == "Gliders" then
                TargetData = self.GliderData
            end

            Data.Button = Button

            if Button.Name == "Featured" then
                Data.Template = self.FeaturedPage.Template:Clone()
                self.FeaturedPage.Template.Parent = nil
            elseif Button.Name == "Coins" then
                Data.Template = self.CoinPage.Template:Clone()
                self.CoinPage.Template.Parent = nil
            elseif Button.Name == "Gliders" then
                Data.Template = self.GliderPage.Template:Clone()
                self.GliderPage.Template.Parent = nil
            end

            Data.Template.Parent = nil

            for Index, _Data in TargetData do
                local ItemTemplate = Data.Template:Clone()
                ItemTemplate.LayoutOrder = Index
                if _Data.Type == "Gliders" then
                    local GliderId = _Data.ItemInfo.Name
                    if GliderId == nil then print("GliderId is nil", _Data) end
                    local Glider = ReplicatedStorage.Assets.Gliders:FindFirstChild(GliderId)

                    if not Glider then
                        print("Glider Not Found", GliderId)
                        continue
                    else
                        print("Glider Found", GliderId)
                    end

                    local OriginalSize = ItemTemplate.Buy.Size

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

                    ItemTemplate.Label.Text = GliderId
                    ItemTemplate.Name = GliderId

                    ItemTemplate.Parent = self.Items[Button.Name]

                    local BuyButton = ItemTemplate.Buy
                    local Owned = _Data.ItemInfo.Owned

                    BuyButton.Main.Label.Text = _Data.ItemInfo.Price

                    BuyButton:SetAttribute("ProductId", GliderId)

                    RegistedProducts[GliderId] = BuyButton

                    if Owned then
                        ItemTemplate.Buy.Main.Label.Text = "Owned"
                    end

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

                        if not Owned then
                            self.ShopService:BuyGlider(GliderId):andThen(function(Data)
                                if Data then
                                    print(Data)
                                end
                            end)
                        end

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
                local ProductId = TargetType.ProductId
                local Owned

                BuyButton:SetAttribute("ProductId", ProductId)

                RegistedProducts[ProductId] = BuyButton

                if Button.Name == "Featured" then
                    Owned = MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, ProductId)
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

                ItemTemplate.Parent = self.Items[Button.Name]
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
                if Data.Button.Name == "Featured" then
                    self.UIPageLayout:JumpTo(self.FeaturedPage)
                elseif Data.Button.Name == "Coins" then
                    self.UIPageLayout:JumpTo(self.CoinPage)
                elseif Data.Button.Name == "Gliders" then
                    self.UIPageLayout:JumpTo(self.GliderPage)
                end
                JumpTo(Data.Button.Name)
                Data.Tweens.Pressed.Completed:Wait()
                if Data.Button:GetAttribute("Hovered") then
                    Data.Tweens.Hovered:Play()
                else
                    Data.Tweens.Unhovered:Play()
                end
            end)

            self.UIPageLayout:JumpTo(self.CoinPage)

            JumpTo(StartingPage)

            self.ActiveButtons[Button] = Data
        end
    end

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

MarketPlaceService.PromptProductPurchaseFinished:Connect(function(Player, ProductId, PurchaseSuccess)
    if PurchaseSuccess then
        print("Product Purchase Success", ProductId)
    else
        print("Product Purchase Failed", ProductId)
    end
end)

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