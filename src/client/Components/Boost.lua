local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GliderController
local CharacterController

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

function Boost.Start(self)
    repeat task.wait() until Knit.FullyStarted

    if not GliderController then
        GliderController = Knit.GetController("GliderController")
    end

    if not CharacterController then
        CharacterController = Knit.GetController("CharacterController")
    end

    self.Pad.Touched:Connect(function(Hit)
        local Root = Hit.Parent:FindFirstChild("HumanoidRootPart")
        local Humanoid = Hit.Parent:FindFirstChild("Humanoid")
        
        if not Root then return end
        if not Humanoid then return end

        local Character = Hit.Parent
        local Glider

        for i, Object in Character:GetChildren() do
            if CollectionService:HasTag(Object, "Glider") then
                Glider = Object
                break
            end
        end

        if not Glider then return end

        local Handle = Glider:FindFirstChild("Handle")
        if not Handle then print("Glider has no handle") return end
        
        local Boost = Glider.Handle:WaitForChild("Boost")
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
        end

        local PushPower = self.Pad:GetAttribute("PushPower")
        local PushDirection = self.Pad:GetAttribute("PushDirection")
        local CurrentMass = getMass(Hit.Parent)

        if Root:GetAttribute("Boost") then
            PushPower = PushPower * 1.2
        end

        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        CharacterController:PlayAnimation("Boost")

        VectorForce.RelativeTo = Enum.ActuatorRelativeTo.World

        local CurrentForce = VectorForce.Force
        local TargetForce = Vector3.new(0, PushPower + CurrentMass * PushDirection.Y, -math.abs(PushPower + CurrentMass * PushDirection.Z))
        local Tween = TweenService:Create(VectorForce, TweenInfo.new(.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Force = TargetForce + CurrentForce})

        Character:SetAttribute("AcumulatedForce", TargetForce.Z)
        SFX.Boost:Play()
        Tween:Play()
        Tween.Completed:Wait()
        Root:SetAttribute("Boost", false)

    end)
end

return Boost