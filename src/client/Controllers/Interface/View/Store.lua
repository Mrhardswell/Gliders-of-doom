local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Store = {}

function Store.new(ScreenGui, Interface)
    local self = {}

    self.ShopService = Knit.GetService("ShopService")

    self.ScreenGui = ScreenGui
    self.Main = ScreenGui.Main
    self.Items = self.Main.Items
    self.UIPageLayout = self.Items.UIPageLayout

    self.FeaturedPage = self.Items.Featured
    self.CoinPage = self.Items.Coins
    self.GliderPage = self.Items.Gliders

    self.ShopService:CheckGamepasses():andThen(function(Gamepasses)
        self.GamepassData = Gamepasses
    end)

    self.ShopService:GetItemData("Featured"):andThen(function(Featured)
        self.FeaturedData = Featured
    end)

    self.ShopService:GetItemData("Coins"):andThen(function(Coins)
        self.CoinData = Coins
        print(self.CoinData)
    end)

    return self
end

return Store