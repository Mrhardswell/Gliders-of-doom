local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local Player = game:GetService("Players").LocalPlayer

local Spin = {}

local TweenInfos = {
    Hovered = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    Unhovered = TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Pressed = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
}

function Spin.new(ScreenGui, Interface)
    local self = {}

    self.ScreenGui = ScreenGui
    self.Exit = ScreenGui:FindFirstChild("Exit", true)
    self.ExitOriginalSize = self.Exit.Size

    self.Main = ScreenGui:FindFirstChild("Main", true)
    self.SpinFrame = self.Main:FindFirstChild("SpinFrame")

    self.WheelService = Knit.GetService("WheelService")

    self.Buttons = {
        Spin1 = ScreenGui.WheelSpin:FindFirstChild("Spin1"),
        Spin5 = ScreenGui.WheelSpin:FindFirstChild("Spin5"),
        Spin10 = ScreenGui.WheelSpin:FindFirstChild("Spin10"),
    }

    self.Products = {
        Spin1 = 1687767812,
        Spin5 = 1687767849,
        Spin10 = 1687767990,
    }

    for Name, Button in self.Buttons do
        local ProductId = self.Products[Name]
        if ProductId then
            local ProductInfo = MarketplaceService:GetProductInfo(ProductId, Enum.InfoType.Product)
            if Name == "Spin1" then
                Button.Contents.Title.Text = "Spin!"
            else
                Button.Contents.Title.Text = string.format("R$ %s",ProductInfo.PriceInRobux)
            end
        end
    
    end

    Player.SpinTime:GetPropertyChangedSignal("Value"):Connect(function()
        local IsInGroup =  Player:IsInGroup(33193007)

        if IsInGroup then
            SpinAmount = 3
        else
            SpinAmount = 1
        end
        self.Buttons.Spin1.NextSpin.Text = "+"..SpinAmount.." Spins In "..Player.SpinTime.Value.."."
    end)
    
    self.WheelService:GetPrizes():andThen(function(Prizes)
        self.GetPrizes = Prizes
        print(self.GetPrizes)
    end)

    self.RequestSpin = self.WheelService.RequestSpin

    self.Tweens = {

        Exit = {

            Hovered = TweenService:Create(self.Exit, TweenInfos.Hovered, {
                Size = self.ExitOriginalSize + UDim2.new(0, 3, 0, 3)
            }),

            Unhovered = TweenService:Create(self.Exit, TweenInfos.Unhovered, {
                Size = self.ExitOriginalSize
            }),

            Pressed = TweenService:Create(self.Exit, TweenInfos.Pressed, {
                Size = self.ExitOriginalSize - UDim2.new(0, 3, 0, 3)
            })

        }

    }

    self.Exit:SetAttribute("Hovered", false)

    self.Exit.MouseButton1Click:Connect(function()
        self.Tweens.Exit.Pressed:Play()

        Interface:CloseUI(ScreenGui.Name)

        self.Tweens.Exit.Pressed.Completed:Wait()

        if self.Exit:GetAttribute("Hovered") then
            self.Tweens.Exit.Hovered:Play()
        else
            self.Tweens.Exit.Unhovered:Play()
        end

    end)

    self.Exit.MouseEnter:Connect(function()
        self.Exit:SetAttribute("Hovered", true)
    end)

    self.Exit.MouseLeave:Connect(function()
        self.Exit:SetAttribute("Hovered", false)
    end)

    self.Exit:GetAttributeChangedSignal("Hovered"):Connect(function()
        if self.Exit:GetAttribute("Hovered") then
            self.Tweens.Exit.Hovered:Play()
        else
            self.Tweens.Exit.Unhovered:Play()
        end
    end)

    return self
end

return Spin