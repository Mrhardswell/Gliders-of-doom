local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GliderController
local CharacterController

local Player = Players.LocalPlayer
local SFX = SoundService.SFX

local Fan = Knit.Component.new {
    Tag = "Fan";
}

local BoostTime = 1

function Fan:Construct()
    self.Fan = self.Instance
    self.Hitbox = self.Fan:WaitForChild("Hitbox")
    self.Propeller = self.Fan:WaitForChild("Propeller")
    self.FanSound = SFX.Fan:Clone()

    self.FanSound.Parent = self.Hitbox
    self.FanSound:Play()
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

function Fan:Spin()
    self.Propeller:GetAttributeChangedSignal("Active"):Connect(function()
        if self.Propeller:GetAttribute("Active") then

            if self.Connection then
                self.Connection:Disconnect()
            end

            self.Connection = RunService.RenderStepped:Connect(function(deltaTime)
                self.Propeller.CFrame = self.Propeller.CFrame * CFrame.Angles(0, 0, 2 * deltaTime)
            end)
        else
            self.Connection:Disconnect()
        end
    end)

    self.Propeller:SetAttribute("Active", true)
end

function Fan.Start(self)
    repeat task.wait() until Knit.FullyStarted

    if not GliderController then
        GliderController = Knit.GetController("GliderController")
    end

    if not CharacterController then
        CharacterController = Knit.GetController("CharacterController")
    end

    self.Hitbox.Touched:Connect(function(Hit)
        print("touch")
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

        local BodyThrust = Root:WaitForChild("BodyThrust")
        if not BodyThrust then print("Root has no body thrust") return end

        local isPlayer = Players:GetPlayerFromCharacter(Hit.Parent)
        if isPlayer then
            if isPlayer ~= Player then
                return
            end
        end

        local PushPower = self.Fan:GetAttribute("PushPower")
        local LookVectorAxis = self.Fan:GetAttribute("Axis")

        if Root:GetAttribute("Boost") then return end

        if not Root:GetAttribute("Boost") then
            Root:SetAttribute("Boost", true)
        end

        VectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
        local CurrentForce = VectorForce.Force
        local TargetForce

        local Total = PushPower + getMass(Hit.Parent) * self.Hitbox.CFrame.LookVector.Y

        if LookVectorAxis == "X" then
            TargetForce = Vector3.new(0, 0, math.abs(Total))
        elseif LookVectorAxis == "Y" then
            TargetForce = Vector3.new(0, Total, 0)
        elseif LookVectorAxis == "Z" then
            TargetForce = Vector3.new(Total, 0, 0)
        end

        Character:SetAttribute("AcumulatedForce", TargetForce.Z)

        BodyThrust.Force = TargetForce

        task.wait(BoostTime)

        BodyThrust.Force = Vector3.new(0, 0, 0)

        Root:SetAttribute("Boost", false)
    end)

    self:Spin()

end

return Fan