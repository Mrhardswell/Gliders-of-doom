local Hud = {}
local Buttons = {}

local SocialService = game:GetService("SocialService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local UISounds = SoundService:WaitForChild("UI")

local Bonuses = require(script.Bonuses)

local Player = game.Players.LocalPlayer
local leaderstats = Player:WaitForChild("leaderstats")

local Coins = leaderstats:WaitForChild("Coins")

local Tween_Infos = {
    Hovered = TweenInfo.new(0.15, Enum.EasingStyle.Sine , Enum.EasingDirection.Out),
    Unhovered = TweenInfo.new(0.15, Enum.EasingStyle.Bounce , Enum.EasingDirection.Out),
    PopUp = TweenInfo.new(.2, Enum.EasingStyle.Sine , Enum.EasingDirection.Out, 0, true),
    UGCText = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true)
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

local targetDate = os.time({
    year = 2023,
    month = 12,
    day = 16,
    hour = 18,
    min = 0,
    sec = 0
})

local function UpdateCountdownDisplay(object)
    local Time = os.date("!*t", os.time())  
    local currentDate = os.time(Time)
    local secondsLeft = targetDate - currentDate
    
    if secondsLeft > 0 then
        local days = math.floor(secondsLeft / (24 * 60 * 60))
        local hours = math.floor((secondsLeft % (24 * 60 * 60)) / (60 * 60))
        local minutes = math.floor((secondsLeft % (60 * 60)) / 60)
    
        object.Text = string.format("%dd %02dh %02dm", days, hours, minutes) 
    end

    return secondsLeft
end

local function HandleGliderShowcase(GliderShowcase, Interface)
    if not GliderShowcase then return end
    
    GliderShowcase.MouseButton1Click:Connect(function()
        MarketplaceService:PromptGamePassPurchase(Player,  652764638)
    end) 

    task.spawn(function()
        while true do
            local secondsLeft = UpdateCountdownDisplay(GliderShowcase.Timer)

            if secondsLeft <= 0 then
                GliderShowcase.Visible = false
                return
            end

            task.wait(1)
        end
    end)

    task.spawn(function()
        while true do
            GliderShowcase.Sunburst.Rotation += 1
            task.wait()
        end
    end)
end 

local function AnimateUGCText(UGCText)
    local ugcTextTween = TweenService:Create(UGCText, Tween_Infos.UGCText, {Rotation = 20})
    ugcTextTween:Play()
end

local function AnimateSpinIcon(SpinIcon)
    task.spawn(function()
        while SpinIcon do
            SpinIcon.Rotation += 1
            task.wait()
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
    self.UGCText = ScreenGui:WaitForChild("UGCText")
    self.Gifts = ScreenGui:WaitForChild("Gifts")
    self.Bonuses = ScreenGui:WaitForChild("Bonuses")

    HandleGliderShowcase(self.GliderShowcase, Interface)

    AnimateUGCText(self.UGCText)

    self.BuyButtons = {
        Coins = self.ValueDisplays.Coins.Buy,
    }

    for _, Button in self.SideButtons:GetChildren() do
        if Button:IsA("TextButton") or Button:IsA("ImageButton") then
            HandleButton(Button, Interface)

            if Button.Name == "Spin" then
                AnimateSpinIcon(Button.SpinIcon)
            end
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