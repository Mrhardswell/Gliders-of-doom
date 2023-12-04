local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local SFX = SoundService.SFX
local DeathSounds = SFX.DeathSounds:GetChildren()
local Impact = SFX.Impact

local Killbox = Knit.Component.new {
    Tag = "Killbox",
}

function Killbox:Construct()
    self.Model = self.Instance
end

function Killbox.Start(self)
    repeat task.wait() until Knit.FullyStarted

    self.Model.Touched:Connect(function(Hit)
        local Humanoid = Hit.Parent:FindFirstChild("Humanoid")
        if not Humanoid then return end
        if Humanoid:GetAttribute("Ragdoll") then return end
        Humanoid:SetAttribute("Ragdoll", true)
        Humanoid:TakeDamage(Humanoid.MaxHealth)
        Impact:Play()
        local DeathSound = DeathSounds[math.random(1, #DeathSounds)]
        DeathSound:Play()
    end)

end

return Killbox