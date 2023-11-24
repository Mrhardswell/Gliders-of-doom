local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GliderController = nil

local Player = Players.LocalPlayer
local SFX = SoundService.SFX

local Boost = Knit.Component.new {
    Tag = "Boost";
}

function Boost:Construct()
    self.Pad = self.Instance
end

local function getMass(Model)
    local Mass = 0
    for i, Object in Model:GetDescendants() do
        if Object:IsA("BasePart") or Object:IsA("MeshPart") then
            Mass += Object:GetMass()
        end
    end
    return Mass
end

local Cooldown = 1

function Boost.Start(self)
    repeat task.wait() until Knit.FullyStarted

    if not GliderController then
        GliderController = Knit.GetController("GliderController")
    end

    self.Pad.Touched:Connect(function(Hit)
        local Root = Hit.Parent:FindFirstChild("HumanoidRootPart")
        local Humanoid = Hit.Parent:FindFirstChild("Humanoid")
        
        if not Root then return end
        if not Humanoid then return end

        local Character = Hit.Parent
        local Glider = GliderController.GetGlider(Character)

        local Boost = Glider:FindFirstChild("Boost", true)
        if not Boost then print("Glider has no boost attachment") return end

        local VectorForce = Boost:FindFirstChild("VectorForce")
        if not VectorForce then print("Boost has no vector force") return end

        local isPlayer = Players:GetPlayerFromCharacter(Hit.Parent)
        if isPlayer then
            if isPlayer ~= Player then
                return
            end
        end

        if not Root:GetAttribute("Boost") then
            Root:SetAttribute("Boost", true)
        else
            return
        end

        local PushPower = self.Pad:GetAttribute("PushPower")
        local PushDirection = self.Pad:GetAttribute("PushDirection")
        local CurrentMass = getMass(Hit.Parent)

        VectorForce.RelativeTo = Enum.ActuatorRelativeTo.World

        local AccumulatedForce = Character:GetAttribute("AcumulatedForce") or 0
        local CurrentForce = VectorForce.Force

        local BaseResult = CurrentMass * PushPower + AccumulatedForce + CurrentForce.Z

        local TargetForce = Vector3.new(0, CurrentForce.Y + BaseResult * PushDirection.Y, -math.abs(CurrentForce.Z + BaseResult * PushDirection.Z))

        VectorForce.Force = TargetForce

        Character:SetAttribute("AcumulatedForce", TargetForce.Z)

        SFX.Boost:Play()
        task.wait(Cooldown)

        Root:SetAttribute("Boost", false)

    end)
end

return Boost