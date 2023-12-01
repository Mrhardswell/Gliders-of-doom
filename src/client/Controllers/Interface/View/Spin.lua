local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Spin = {}

local TweenInfos = {
    Hovered = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    Unhovered = TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Pressed = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
}

function Spin.new(ScreenGui, Interface)
    local self = {}

    self.WheelService = Knit.GetService("WheelService")

    self.ScreenGui = ScreenGui
    self.Exit = ScreenGui:FindFirstChild("Exit", true)
    self.Main = ScreenGui:FindFirstChild("Main", true)
    self.SpinFrame = self.Main:FindFirstChild("SpinFrame")

    self.Spin1 = ScreenGui.WheelSpin:FindFirstChild("Spin1")
    self.Spin5 = ScreenGui.WheelSpin:FindFirstChild("Spin5")
    self.Spin10 = ScreenGui.WheelSpin:FindFirstChild("Spin10")

    self.ExitOriginalSize = self.Exit.Size

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