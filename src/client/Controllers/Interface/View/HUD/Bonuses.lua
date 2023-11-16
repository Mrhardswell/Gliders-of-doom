local Bonuses = {}

local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local MarketplaceService = game:GetService("MarketplaceService")

local UISounds = SoundService:WaitForChild("UI")

local _Interface

local TweenInfos = {
    Hovered = TweenInfo.new(0.15, Enum.EasingStyle.Sine , Enum.EasingDirection.Out),
    Unhovered = TweenInfo.new(0.1, Enum.EasingStyle.Bounce , Enum.EasingDirection.Out),
    Pressed = TweenInfo.new(0.1, Enum.EasingStyle.Sine , Enum.EasingDirection.Out),
}

function Bonuses.Register(BoolValue, Element, Interface)
    local self = {}
    _Interface = Interface

    self.Name = BoolValue.Name
    self.Value = BoolValue.Value

    self.OriginalSize = Element.Size

    Element:SetAttribute("Hovered", false)

    self.Amount = Element:WaitForChild("Amount")

    if self.Value then
        self.Amount.Text = "x2"
    else
        self.Amount.Text = "x1"
    end

    self.Tweens = {
        Hovered = TweenService:Create(Element, TweenInfos.Hovered, {
            Size = self.OriginalSize + UDim2.new(0, 3, 0, 3);
        }),
        Unhovered = TweenService:Create(Element, TweenInfos.Unhovered, {
            Size = self.OriginalSize;
        }),
        Pressed = TweenService:Create(Element, TweenInfos.Pressed, {
            Size = self.OriginalSize - UDim2.new(0, 3, 0, 3);
        }),
    }

    BoolValue.Changed:Connect(function()
        self.Value = BoolValue.Value
        if self.Value then
            self.Amount.Text = "x2"
        else
            self.Amount.Text = "x1"
        end
    end)

    Element.MouseEnter:Connect(function()
        Element:SetAttribute("Hovered", true)
    end)

    Element.MouseLeave:Connect(function()
        Element:SetAttribute("Hovered", false)
    end)

    Element.MouseButton1Click:Connect(function()
        self.Tweens.Pressed:Play()
        UISounds.Click:Play()
        if not self.Value then
            Interface.MultiplierService:BuyMultiplier(self.Name)
        else
            print("Already bought")
        end
        self.Tweens.Pressed.Completed:Wait()
        if Element:GetAttribute("Hovered") then
            self.Tweens.Hovered:Play()
        else
            self.Tweens.Unhovered:Play()
        end
    end)

    Element:GetAttributeChangedSignal("Hovered"):Connect(function()
        if Element:GetAttribute("Hovered") then
            self.Tweens.Hovered:Play()
            UISounds.Hover:Play()
        else
            self.Tweens.Unhovered:Play()
        end
    end)

    return self
end

return Bonuses