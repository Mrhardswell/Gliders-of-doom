local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local SFX = SoundService.SFX

local Knit = require(ReplicatedStorage.Packages.Knit)

local Tornado = Knit.Component.new {
    Tag = "Tornado",
}

function Tornado:Construct()
    self.Model = self.Instance
end

local function getMass(model)
    local mass = 0;
    for _, Item in model:GetDescendants() do
        if Item:IsA("BasePart") or Item:IsA("MeshPart") then
            mass += Item:GetMass();
        end
    end
    return mass;
end

local Cooldown = 1
local BodyVelocity = Instance.new("BodyVelocity")

function Tornado.Start(self)
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
        local TweenUp = TweenService:Create(BodyVelocity, TweenInfo.new(0.75), {Velocity = Vector3.new(PushDirection.X * PushPower * CurrentMass, PushDirection.Y * PushPower * CurrentMass, PushDirection.Z * PushPower * CurrentMass)})

        SFX.Boost:Play()

        BodyVelocity.Parent = Root
        BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)

        TweenUp:Play()
        TweenUp.Completed:Wait()
        TweenUp:Destroy()

        BodyVelocity.Parent = nil
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)

        Root:SetAttribute("Tornado", false)
    end)
end

return Tornado