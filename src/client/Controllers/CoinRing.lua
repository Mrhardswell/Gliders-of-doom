local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local coinModel = ReplicatedStorage.Assets.Coin
local player = Players.LocalPlayer
local SFX = SoundService.SFX

local CoinRingController = Knit.CreateController {
    Name = "CoinRingController"
}

function CoinRingController:KnitStart()

end

local function quadBezier(t, p0, p1, p2)
    return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

Net:Connect("CreateCoins", function(Model)
    local ring = Model.Ring
    local coinCache = Model.CoinCache
    local flare = ring.Attachment.Flare
    local orientation = 0
    local offsetSize = ring.Size.Magnitude / 3
    local originalSize = ring.Size
    local ringTweenInfo = TweenInfo.new(.33, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local ringTween = TweenService:Create(ring, ringTweenInfo, {Size = originalSize * 1.5, Transparency = 1})
    local speed = 10

    if ring.Size ~= originalSize then return end

    SFX.CoinRing:Play()

    for i = 1, 30, 1 do
        local angle = (i-1) * (2 * math.pi / 30) 
        local coinModelClone = coinModel:Clone()
        coinModelClone.Parent = coinCache
    
        local offset = Vector3.new(math.cos(angle), math.sin(angle), 0) * offsetSize
        coinModelClone.Position = ring.Position + offset
    
        coinModelClone.CFrame *= CFrame.Angles(0, 0, math.rad(orientation + math.random(-10, 10)))

        task.spawn(function()
            local character = player.Character
            local humanoid = character.Humanoid
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            local startTime = os.time()

            while (humanoidRootPart.Position - coinModelClone.Position).Magnitude > 10 do
                if humanoid.Health <= 0 or speed <= 0 then break end

                local t = (os.time() - startTime) / speed
                local bezierPosition = Vector3.new(
                    quadBezier(t, coinModelClone.Position.X, humanoidRootPart.Position.X + math.random(-5, 5), humanoidRootPart.Position.X),
                    quadBezier(t, coinModelClone.Position.Y, humanoidRootPart.Position.Y + math.random(-5, 5), humanoidRootPart.Position.Y),
                    quadBezier(t, coinModelClone.Position.Z, humanoidRootPart.Position.Z + math.random(-5, 5), humanoidRootPart.Position.Z)
                )
                coinModelClone.Position = bezierPosition
                task.wait()
            end

            coinModelClone:Destroy()
        end)
    end

    task.spawn(function()
        while #coinCache:GetChildren() ~= 0 and speed > 1 do
            speed = math.max(0, speed - 0.1)
            task.wait()
        end
    end)
    

    if ring then
        flare:Emit(5)
        ringTween:Play()
        task.wait(30)
        ring.Size = originalSize
        ring.Transparency = 0.15
    end
end)

return CoinRingController
