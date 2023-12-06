local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = game.Players.LocalPlayer
local ActiveCheckpoint = Player:WaitForChild("ActiveCheckpoint")

local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local Interval = 0.3
local Current = 0

local OutOfBoundsController = Knit.CreateController { Name = "OutOfBoundsController" }

local OutOfBoundsData = {
    XLeft = -646,
    XRight = 846,
    YBottom = 862,
    YTop = 1606,
    ZBack = 124
}

local Connection = nil

local function Cleanup()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
end

function OutOfBoundsController:ListenForOutOfBounds(Character)
    Cleanup()

    local humanoidRootPart = Character:WaitForChild("HumanoidRootPart")

    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        Current += deltaTime
        if Current < Interval then return end
        Current = 0

        if humanoidRootPart.Position.Z > OutOfBoundsData.ZBack or
            humanoidRootPart.Position.X < OutOfBoundsData.XLeft or
            humanoidRootPart.Position.X > OutOfBoundsData.XRight or
            humanoidRootPart.Position.Y > OutOfBoundsData.YTop  or
            humanoidRootPart.Position.Y < OutOfBoundsData.YBottom then

            StarterGui:SetCore("SendNotification", {
                Title = "Out of Bounds";
                Text = "You went out of bounds!";
                Duration = 3;
            })

            Character.Humanoid.Health = 0
            Connection:Disconnect()
        end

    end)
end

function OutOfBoundsController:KnitStart()
    local Character = Player.Character or Player.CharacterAdded:Wait()

    self:ListenForOutOfBounds(Character)

    Player.CharacterAdded:Connect(function(Character)
        self:ListenForOutOfBounds(Character)
    end)

end

return OutOfBoundsController