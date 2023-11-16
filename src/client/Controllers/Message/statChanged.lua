local statChanged = {}

local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Mouse = Player:GetMouse()

function statChanged.Changed(Differance, StatFrame)
    local Icon = StatFrame.Icon
    local IconScreenPos = Icon.AbsolutePosition

    local MousePos = UserInputService:GetMouseLocation()
    local Clone = Icon:Clone()

    Clone.Parent = Player.PlayerGui.HUD
    Clone.Position = UDim2.new(0, MousePos.X, 0, MousePos.Y)
    Clone.Size = UDim2.new(0, 0, 0, 0)

    local IconOriginalSize = Icon.Size

    local IconTweens = {
        Normal = TweenService:Create(Icon, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Size = IconOriginalSize;
        }),

        Bounce = TweenService:Create(Icon, TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
            Size = IconOriginalSize + UDim2.new(0, 10, 0, 10);
        }),
    }

    local PopUpTween = TweenService:Create(Clone, TweenInfo.new(0.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out ), {
        Position = UDim2.new(0, Mouse.X + math.random(-10, 10), 0, Mouse.Y + math.random(-10, 10)), Size = UDim2.new(0, 80, 0, 80)
    })

    local Tween = TweenService:Create(Clone, TweenInfo.new(1, Enum.EasingStyle.Sine), {
        Position = UDim2.new(0, IconScreenPos.X + 15, 0, IconScreenPos.Y + 75), Size = UDim2.new(0, 40, 0, 40)
    })

    local AmountLabel = Instance.new("TextLabel")

    AmountLabel.Parent = Clone
    AmountLabel.BackgroundTransparency = 1
    AmountLabel.Position = UDim2.new(0, 0, 1, 0)
    AmountLabel.Size = UDim2.new(1, 0, 0, 20)
    AmountLabel.Font = Enum.Font.SourceSansBold
    AmountLabel.TextColor3 = Color3.new(1, 1, 1)
    AmountLabel.TextStrokeTransparency = 0.5
    AmountLabel.TextScaled = true
    AmountLabel.Text = Differance

    PopUpTween:Play()
    PopUpTween.Completed:Wait()

    Tween:Play()
    Tween.Completed:Connect(function()
        IconTweens.Bounce:Play()
        PopUpTween:Destroy()
        Clone:Destroy()
        Tween:Destroy()
    end)

    IconTweens.Bounce.Completed:Connect(function()
        IconTweens.Normal:Play()
        IconTweens.Normal.Completed:Wait()
        for _, Tween in IconTweens do
            Tween:Destroy()
        end
    end)

end

return statChanged