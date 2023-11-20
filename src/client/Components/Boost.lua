local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local SFX = SoundService.SFX

local Boost = Knit.Component.new {
    Tag = "Boost";
}

function Boost:Construct()
    self.Pad = self.Instance
end

local function getMass(model)
    assert(model and model:IsA("Model"), "Model argument of getMass must be a model.");
    local mass = 0;
    for i,v in pairs(model:GetDescendants()) do
        if(v:IsA("BasePart")) then
            mass += v:GetMass();
        end
    end
    return mass;
end

local BoostStrength = nil
local Cooldown = 1

function Boost.Start(self)
    self.Pad.Touched:Connect(function(Hit)
        local Root = Hit.Parent:FindFirstChild("HumanoidRootPart")
        local Humanoid = Hit.Parent:FindFirstChild("Humanoid")
        if not Root then return end
        if not Humanoid then return end

        if not Root:GetAttribute("Boost") then
            Root:SetAttribute("Boost", true)
        else
            return
        end

        BoostStrength = getMass(Hit.Parent) * 100000
        Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        SFX.Boost:Play()
        Root.Velocity = Root.CFrame.LookVector + Vector3.new(0, 0.01, 0) * BoostStrength
        Root:SetAttribute("Boost", false)

    end)
end

return Boost