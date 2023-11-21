local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

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

function Boost.Start(self)
    self.Pad.Touched:Connect(function(Hit)
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

        if not Root:GetAttribute("Boost") then
            Root:SetAttribute("Boost", true)
        else
            return
        end

        local Power = self.Pad:GetAttribute("Power")

        local CurrentMass = getMass(Hit.Parent)
        local TweenUp = TweenService:Create(BodyVelocity, TweenInfo.new(0.75), {Velocity = Vector3.new(0, Power * CurrentMass, -Power * CurrentMass)})

        Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

        SFX.Boost:Play()

        BodyVelocity.Parent = Root
        BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)

        TweenUp:Play()
        TweenUp.Completed:Wait()
        TweenUp:Destroy()

        BodyVelocity.Parent = nil
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)

        Root:SetAttribute("Boost", false)

    end)
end

return Boost