local Hud = {}
local Buttons = {}

local SocialService = game:GetService("SocialService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local UISounds = SoundService:WaitForChild("UI")

local Bonuses = require(script.Bonuses)

local Player = game.Players.LocalPlayer
local leaderstats = Player:WaitForChild("leaderstats")

local Coins = leaderstats:WaitForChild("Coins")

local Tween_Infos = {
    Hovered = TweenInfo.new(0.15, Enum.EasingStyle.Sine , Enum.EasingDirection.Out),
    Unhovered = TweenInfo.new(0.15, Enum.EasingStyle.Bounce , Enum.EasingDirection.Out),
    PopUp = TweenInfo.new(.2, Enum.EasingStyle.Sine , Enum.EasingDirection.Out, 0, true),
}

local function HandleButton(Button, Interface)
    Buttons[Button.Name] = {}
    Buttons[Button.Name].Button = Button

    local ButtonImage = Button:FindFirstChildWhichIsA("ImageLabel")
    local OriginalSize = ButtonImage.Size

    local Goals = {
        Normal = { Rotation = 0, Size = OriginalSize},
        Hovered = { Rotation = 15, Size = OriginalSize + UDim2.new(0, 3, 0, 3)},
        Pressed = { Rotation = -15}, Size = OriginalSize - UDim2.new(0, 3, 0, 3),
    }

    local Tweens = {
        Hovered = TweenService:Create(ButtonImage, Tween_Infos.Hovered, Goals.Hovered),
        Unhovered = TweenService:Create(ButtonImage, Tween_Infos.Unhovered, Goals.Normal),
        Pressed = TweenService:Create(ButtonImage, Tween_Infos.Unhovered, Goals.Pressed),
    }

    Button:SetAttribute("Hovered", false)

    Buttons[Button.Name].MouseButton1Click = Button.MouseButton1Click:Connect(function()
        UISounds.Click:Play()
        Tweens.Pressed:Play()
        Tweens.Pressed.Completed:Wait()
        if Button:GetAttribute("Hovered") then
            Tweens.Hovered:Play()
        else
            Tweens.Unhovered:Play()
        end
        Interface:ToggleUI(Button.Name)
    end)

    Buttons[Button.Name].MouseEnter = Button.MouseEnter:Connect(function()
        Button:SetAttribute("Hovered", true)
    end)

    Buttons[Button.Name].MouseLeave = Button.MouseLeave:Connect(function()
        Button:SetAttribute("Hovered", false)
    end)

    Button:GetAttributeChangedSignal("Hovered"):Connect(function()
        if Button:GetAttribute("Hovered") then
            Tweens.Hovered:Play()
            UISounds.Hover:Play()
        else
            Tweens.Unhovered:Play()
        end
    end)

end

function Hud.new(ScreenGui, Interface)
    local self = {}

    Interface.statChanged = Instance.new("BindableEvent")
    Interface.statChanged.Name = "statChanged"

    self.ScreenGui = ScreenGui
    self.ValueDisplays = ScreenGui:WaitForChild("ValueDisplays")
    self.SideButtons = ScreenGui:WaitForChild("SideButtons")
    self.Invite = ScreenGui:WaitForChild("Invite")
    self.GliderShowcase = ScreenGui:WaitForChild("GliderShowcase")
    self.Gifts = ScreenGui:WaitForChild("Gifts")
    self.Bonuses = ScreenGui:WaitForChild("Bonuses")

    self.BuyButtons = {
        Coins = self.ValueDisplays.Coins.Buy,
    }

    for _, Button in self.SideButtons:GetChildren() do
        if Button:IsA("TextButton") or Button:IsA("ImageButton") then
            HandleButton(Button, Interface)
        end
    end

    for _, Bonus in self.Bonuses:GetChildren() do
        if Bonus:IsA("ImageButton") then
            local BoolValue = Player.Bonuses:WaitForChild(Bonus.Name)
            local _Bonus = Bonuses.Register(BoolValue, Bonus, Interface)
            _Bonus.Button = Bonus

        end
    end

    -- Values
    self.ValueDisplays.Coins.Amount.Text = Coins.Value
    self.PreviousCoins = Coins.Value
    local CoinIcon = Player.PlayerGui.HUD.ValueDisplays.Coins.Icon

    Coins:GetPropertyChangedSignal("Value"):Connect(function()
        self.ValueDisplays.Coins.Amount.Text = Coins.Value
        SoundService.UI.Coin:Play()
        if not CoinIcon then return end
        local CoinIconSize = CoinIcon.Size


        local Tween = TweenService:Create(CoinIcon, Tween_Infos.PopUp, {
            Size = CoinIconSize + UDim2.new(0, 5, 0, 5);
        })

        local TextTween = TweenService:Create(self.ValueDisplays.Coins.Amount, Tween_Infos.PopUp, {
            Size = self.ValueDisplays.Coins.Amount.Size + UDim2.new(0, 5, 0, 5);
        })

        Tween:Play()
        TextTween:Play()
        Tween.Completed:Wait()
        Tween:Destroy()
        TextTween:Destroy()
    end)

    -- Invite Button
    local OrginalInviteSize = self.Invite.Button.Icon.Size
    self.Invite:SetAttribute("Hovered", false)

    local tweens = {
        Hovered = TweenService:Create(self.Invite.Button.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Sine , Enum.EasingDirection.Out), {
            Size = OrginalInviteSize + UDim2.new(0, 3, 0, 3);
        }),
        Unhovered = TweenService:Create(self.Invite.Button.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Bounce , Enum.EasingDirection.Out), {
            Size = OrginalInviteSize;
        }),
        Pressed = TweenService:Create(self.Invite.Button.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Sine , Enum.EasingDirection.Out), {
            Size = OrginalInviteSize - UDim2.new(0, 3, 0, 3);
        }),
    }

    self.Invite.Button.MouseButton1Click:Connect(function()
        UISounds.Click:Play()
        tweens.Pressed:Play()
        if not SocialService:CanSendGameInviteAsync(Player) then
            return
        end
        SocialService:PromptGameInvite(Player)
        if self.Invite:GetAttribute("Hovered") then
            tweens.Hovered:Play()
        else
            tweens.Unhovered:Play()
        end
    end)

    self.Invite.Button.MouseEnter:Connect(function()
        self.Invite:SetAttribute("Hovered", true)
    end)

    self.Invite.Button.MouseLeave:Connect(function()
        self.Invite:SetAttribute("Hovered", false)
    end)

    self.Invite:GetAttributeChangedSignal("Hovered"):Connect(function()
        if self.Invite:GetAttribute("Hovered") then
            UISounds.Hover:Play()
            tweens.Hovered:Play()
        else
            tweens.Unhovered:Play()
        end
    end)

    -- Buy Buttons
    for _, Button in self.BuyButtons do
        local OriginalSize = Button.Size

        local Tweens = {
            Hovered = TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Sine , Enum.EasingDirection.Out), {
                Size = OriginalSize + UDim2.new(0, 3, 0, 3);
            }),
            Unhovered = TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Bounce , Enum.EasingDirection.Out), {
                Size = OriginalSize;
            }),
            Pressed = TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Sine , Enum.EasingDirection.Out), {
                Size = OriginalSize - UDim2.new(0, 3, 0, 3);
            }),
        }

        Button.MouseButton1Click:Connect(function()
            UISounds.Click:Play()
            Interface:ToggleUI("Shop")
            Tweens.Pressed:Play()
            Tweens.Pressed.Completed:Wait()
            if Button:GetAttribute("Hovered") then
                Tweens.Hovered:Play()
            else
                Tweens.Unhovered:Play()
            end
        end)

        
        Button:SetAttribute("Hovered", false)

        Button.MouseEnter:Connect(function()
            Button:SetAttribute("Hovered", true)
        end)

        Button.MouseLeave:Connect(function()
            Button:SetAttribute("Hovered", false)
        end)

        Button:GetAttributeChangedSignal("Hovered"):Connect(function()
            if Button:GetAttribute("Hovered") then
                UISounds.Hover:Play()
                Tweens.Hovered:Play()
            else
                Tweens.Unhovered:Play()
            end
        end)

    end

    -- Gift Button
    local OriginalGiftSize = self.Gifts.Button.Icon.Size
    local OriginalGiftRotation = self.Gifts.Button.Icon.Rotation

    self.Gifts:SetAttribute("Hovered", false)

    local GiftTweens = {
        Hovered = TweenService:Create(self.Gifts.Button.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Sine , Enum.EasingDirection.Out), {
            Size = OriginalGiftSize + UDim2.new(0, 3, 0, 3), Rotation = OriginalGiftRotation + 15;
        }),
        Unhovered = TweenService:Create(self.Gifts.Button.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Bounce , Enum.EasingDirection.Out), {
            Size = OriginalGiftSize, Rotation = OriginalGiftRotation;
        }),
        Pressed = TweenService:Create(self.Gifts.Button.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Sine , Enum.EasingDirection.Out), {
            Size = OriginalGiftSize - UDim2.new(0, 3, 0, 3) , Rotation = OriginalGiftRotation + -15;
        }),
    }

    self.Gifts.Button.MouseButton1Click:Connect(function()
        UISounds.Click:Play()
        GiftTweens.Pressed:Play()
        GiftTweens.Pressed.Completed:Wait()
        if self.Gifts:GetAttribute("Hovered") then
            GiftTweens.Hovered:Play()
        else
            GiftTweens.Unhovered:Play()
        end
        Interface:ToggleUI("Gifts")
    end)

    self.Gifts.Button.MouseEnter:Connect(function()
        self.Gifts:SetAttribute("Hovered", true)
    end)

    self.Gifts.Button.MouseLeave:Connect(function()
        self.Gifts:SetAttribute("Hovered", false)
    end)

    self.Gifts:GetAttributeChangedSignal("Hovered"):Connect(function()
        if self.Gifts:GetAttribute("Hovered") then
            UISounds.Hover:Play()
            GiftTweens.Hovered:Play()
        else
            GiftTweens.Unhovered:Play()
        end
    end)

    return self
end

return Hud