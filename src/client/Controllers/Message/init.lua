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
                print("Changed", isKeyword, "by", Differance)
            end
        end

        StarterGui:SetCore("SendNotification", {
            Title = Message.Title;
            Text = Message.Text;
            Duration = Message.Duration;
        })

    end
end)

Net:Connect("GameMessage", function(Message)
    print("GameMessage", Message)
    StarterGui:SetCore("SendNotification", {
        Title = Message.Title;
        Text = Message.Text;
        Duration = Message.Duration;
    })

end)

local WinnerTextTable = {
    [1] = "%s has finished in First Place and got 1 Spin!",
    [2] = "%s has finished in Second Place!",
    [3] = "%s has finished in Third Place!"
}

Net:Connect("DisplayWinner", function(winnerName, winnerCount)
    local winnerText = PlayerGui.HUD.WinnerText
    local textToDisplay

    if winnerCount < 4 then
        textToDisplay = string.format(WinnerTextTable[winnerCount], winnerName)
    else
        textToDisplay = string.format("%s has achieved a win!", winnerName)
    end

    winnerText.Visible = true
    winnerText.Text = textToDisplay
    wait(5)
    winnerText.Visible = false
end)

return Messages
