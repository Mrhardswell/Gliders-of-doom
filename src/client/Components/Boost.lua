local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = Players.LocalPlayer
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

local Cooldown = 1
local BodyThrust = Instance.new("BodyThrust")

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

        Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        SFX.Boost:Play()
        local CurrentMass = getMass(Hit.Parent)
        -- trust up and forward with more than the player's mass
        BodyThrust.Force = Vector3.new(0, CurrentMass * 1.5, CurrentMass * 10000)
        BodyThrust.Location = Root.Position
        BodyThrust.Parent = Root

        task.wait(Cooldown)
        BodyThrust.Parent = nil

        Root:SetAttribute("Boost", false)

    end)
end

return Boost