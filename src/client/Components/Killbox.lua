local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Killbox = Knit.Component.new {
    Tag = "Killbox",
}

function Killbox:Construct()
    self.Model = self.Instance
end

function Killbox.Start(self)

    self.Model.Touched:Connect(function(Hit)
        local Humanoid = Hit.Parent:FindFirstChild("Humanoid")

        if not Humanoid then
            return
        end

        local HumanoidRootPart = Hit.Parent:FindFirstChild("HumanoidRootPart")
        local Impact = HumanoidRootPart:FindFirstChild("Impact")

        if Humanoid:GetAttribute("Ragdoll") then
            return
        end

        Humanoid:SetAttribute("Ragdoll", true)

        if not HumanoidRootPart then return end

        if Impact then
            Impact:Play()
        else
            game.SoundService.SFX.Impact:Clone().Parent = HumanoidRootPart
            Impact = HumanoidRootPart:FindFirstChild("Impact")
            Impact:Play()
        end

        Humanoid.Health = 0

        HumanoidRootPart.Velocity = HumanoidRootPart.Velocity * 0.5

    end)

end

return Killbox