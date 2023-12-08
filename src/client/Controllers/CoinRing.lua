local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local coinModel = ReplicatedStorage.Assets.Coin
local player = Players.LocalPlayer

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
    local orientation = 0

    for i = 1, 10, 1 do
        local angle = (i-1) * (2 * math.pi / 10) 
        local coinModelClone = coinModel:Clone()
        coinModelClone.Parent = Model.CoinCache
    
        local basePosition = Model.Base.Position

        local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * 33
        coinModelClone.Position = basePosition + offset
    
        coinModelClone.CFrame *= CFrame.Angles(0, 0, math.rad(orientation))

        task.spawn(function()
            local character = player.Character
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            local startTime = os.time()

            while (humanoidRootPart.Position - coinModelClone.Position).Magnitude > 5 do
                local t = (os.time() - startTime) / 15
                local bezierPosition = Vector3.new(
                    quadBezier(t, coinModelClone.Position.X, humanoidRootPart.Position.X, humanoidRootPart.Position.X),
                    quadBezier(t, coinModelClone.Position.Y, humanoidRootPart.Position.Y, humanoidRootPart.Position.Y),
                    quadBezier(t, coinModelClone.Position.Z, humanoidRootPart.Position.Z, humanoidRootPart.Position.Z)
                )
                coinModelClone.Position = bezierPosition

                task.wait()
            end

            coinModelClone:Destroy()
        end)
    end

    local originalSize = ring.Size
    local ringTweenInfo = TweenInfo.new(.33, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0.1)
    local ringTween = TweenService:Create(ring, ringTweenInfo, {Size = originalSize * 1.5, Transparency = 1})

    if ring then
        ringTween:Play()
    end
end)

return CoinRingController