local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Net = require(game.ReplicatedStorage.Packages.Net)

local statChanged = require(script.statChanged)

local StarterGui = game:GetService("StarterGui")

local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local HUD = PlayerGui:WaitForChild("HUD")
local ValueDisplays = HUD:WaitForChild("ValueDisplays")

local Messages = Knit.CreateController { Name = "Messages" }

local Bindable = Instance.new("BindableFunction")

local function Callback(Text)
	if Text == "Teleport" then
        print("Teleporting")
        local Target = workspace:GetAttribute("BlockMerchant")
        if Target then
            local Character = game.Players.LocalPlayer.Character
            Character:PivotTo(CFrame.new(Target))
        end
    else
        print("Canceling")
    end
end

Bindable.OnInvoke = Callback

local Keywords = {"Coins", "Gems"}

Net:Connect("BlockMessage", function(Message)
    if Message.Button1 then
        StarterGui:SetCore("SendNotification", {
            Title = Message.Title;
            Text = Message.Text;
            Duration = Message.Duration;
            Button1 = Message.Button1;
            Button2 = Message.Button2;
            Callback = Bindable;
        })
    else
        if not Message.Text then print(Message, "Something Happened") return end
        local isKeyword = string.match(Message.Text, Keywords[1]) or string.match(Message.Text, Keywords[2])
        if isKeyword then
            local isUI = ValueDisplays:FindFirstChild(isKeyword)
            if isUI then
                local Differance = string.match(Message.Text, "%d+")
                local StatFrame = isUI
                statChanged.Changed(Differance, StatFrame)
            end
        end

        StarterGui:SetCore("SendNotification", {
            Title = Message.Title;
            Text = Message.Text;
            Duration = Message.Duration;
        })

    end
end)

return Messages
