local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local coinAssets = ReplicatedStorage.Assets.CoinAssets
local coinModel = coinAssets.Coin
local spawnParticle = coinAssets.SpawnParticle.SpawnParticles
local player = Players.LocalPlayer
local SFX = SoundService.SFX

local CoinRingController = Knit.CreateController {
    Name = "CoinRingController"
}

local function quadBezier(t, p0, p1, p2)
    return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

local function setupCoinRing(model, coinAmount, offsetSize, originalSize)
    local ring = model.Ring
    local coinCache

    if model:GetAttribute("FirstSpawn") then
        model:SetAttribute("FirstSpawn", false)

        coinCache = Instance.new("Folder")
        coinCache.Name = "CoinCache"
        coinCache.Parent = ring

        for i = 1, coinAmount, 1 do
            local angle = (i-1) * (2 * math.pi / coinAmount) 
            local spawnParticleClone = spawnParticle:Clone()
            spawnParticleClone.Parent = ring

            local offset = Vector3.new(math.cos(angle), math.sin(angle), 0) * offsetSize
            spawnParticleClone.WorldPosition = ring.Position + offset

            spawnParticleClone.WorldCFrame *= CFrame.Angles(0, 0, math.rad(math.random(-10, 10)))
        end
    else
        coinCache = ring.CoinCache
    end

    return coinCache
end
function CoinRingController:KnitStart()
    Net:Connect("CreateCoins", function(model)
        model:SetAttribute("Cooldown", true)

        local ring = model.Ring
        local flare = ring.Attachment.Flare

        local offsetSize = ring.Size.Magnitude / 3
        local originalSize = ring.Size
        local coinAmount = 15
        local speed = 10
        
        local coinCache = setupCoinRing(model, coinAmount, offsetSize, originalSize)
    
        local ringTweenInfo = TweenInfo.new(.33, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local ringTween = TweenService:Create(ring, ringTweenInfo, {Size = originalSize * 1.5, Transparency = 1})

        SFX.CoinRing:Play()
    
        for i = 1, coinAmount, 1 do
            local angle = (i-1) * (2 * math.pi / coinAmount) 
            local coinModelClone = coinModel:Clone()
            coinModelClone.Parent = coinCache

            local offset = Vector3.new(math.cos(angle), math.sin(angle), 0) * offsetSize
            coinModelClone.Position = ring.Position + offset
        
            coinModelClone.CFrame *= CFrame.Angles(0, 0, math.rad(math.random(-10, 10)))

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
            for _, particleAttachment in ring:GetChildren() do
                if particleAttachment.Name ~= "SpawnParticles" then continue end

                for _, particle in particleAttachment:GetChildren() do
                    particle:Emit(3)  
                end
            end

            flare:Emit(5)
            ringTween:Play()
        end
    end)

    Net:Connect("ResetRing", function(model, originalSize)
        if not model then return end
        
		model:SetAttribute("Cooldown", false)
		
		if not model:FindFirstChild("Ring") then return end
		
        model.Ring.Size = originalSize
        model.Ring.Transparency = 0.15
    end)
end

return CoinRingController
