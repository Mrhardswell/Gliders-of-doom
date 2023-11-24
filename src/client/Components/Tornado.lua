local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local SFX = SoundService.SFX

local Knit = require(ReplicatedStorage.Packages.Knit)

local GliderController = nil

local Tornado = Knit.Component.new {
    Tag = "Tornado",
}

function Tornado:Construct()
    self.Model = self.Instance
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

function Tornado.Start(self)
    repeat task.wait() until Knit.FullyStarted

    if not GliderController then
        GliderController = Knit.GetController("GliderController")
    end

    if not self.Model.PrimaryPart then print("No primary part", self.Model) return end
    local Moving = self.Model:GetAttribute("Moving")
    if Moving then
        local MovementInfo = TweenInfo.new(self.Model:GetAttribute("MovementTime"), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0)
        local RotationInfo = TweenInfo.new(self.Model:GetAttribute("RotationTime"), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)

        local CurrentPivot = self.Model:GetPivot()
        local Goal = CFrame.new(CurrentPivot.Position + Vector3.new(100, 0, 0))
        local Tween = TweenService:Create(self.Model.PrimaryPart, MovementInfo, {Position = Goal.Position})
        local Rotation = TweenService:Create(self.Model.PrimaryPart, RotationInfo, {Rotation = Vector3.new(0, 360, 0)})

        Tween:Play()
        Rotation:Play()
    end

    self.Model.PrimaryPart.Touched:Connect(function(Hit)
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

        if not Root:GetAttribute("Tornado") then
            Root:SetAttribute("Tornado", true)
        else
            return
        end

        local PushPower = self.Model:GetAttribute("PushPower")
        local PushDirection = self.Model:GetAttribute("PushDirection")
        local CurrentMass = getMass(Hit.Parent)
        local CurrentForce = VectorForce.Force
        local TargetForce = Vector3.new(0, PushPower + CurrentMass * PushDirection.Y, -math.abs(CurrentForce.Z))
        local Tween = TweenService:Create(VectorForce, TweenInfo.new(Cooldown, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Force = TargetForce})

        SFX.Boost:Play()
        Tween:Play()
        Tween.Completed:Wait()
        Character:SetAttribute("AcumulatedForce", TargetForce.Z)
        Root:SetAttribute("Tornado", false)

    end)
end

return Tornado