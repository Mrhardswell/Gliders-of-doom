local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = game.Players.LocalPlayer

local Glider = Knit.CreateController {
    Name = "GliderController";
    Client = {};
}

local Connections = {}
local Camera = workspace.CurrentCamera

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

local function GetGlider(Character)
    for _, Accessory in Character:GetChildren() do
        if CollectionService:HasTag(Accessory, "Glider") then
            return Accessory
        end
    end
end

Glider.GetGlider = GetGlider

local function CharacterAdded(Character)
    local Humanoid = Character:WaitForChild("Humanoid")
    local humanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if humanoidRootPart then

        local BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(0, 0, 0)
        BodyGyro.P = getMass(Character) * 10000

        BodyGyro.D = 1000
        BodyGyro.Parent = humanoidRootPart

        for Name, Connection in Connections do
            Connection:Disconnect()
            Connections[Name] = nil
        end

        local _Glider = GetGlider(Character)
        local Boost = _Glider:FindFirstChild("Boost", true)
        local VectorForce = Boost:FindFirstChild("VectorForce")

        local BaseForce = 1500
        local MaxForce = 10000

        Connections["RunService"] = RunService.RenderStepped:Connect(function(deltaTime)
            if Humanoid:GetState() == (Enum.HumanoidStateType.Freefall or Enum.HumanoidStateType.FallingDown) then
                local Root = Character:FindFirstChild("HumanoidRootPart")
                if not Root then return end

                local CameraCF = Camera.CFrame
                BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                BodyGyro.CFrame = CameraCF

                if not Character:GetAttribute("Boost") or not Character:GetAttribute("Tornado") then

                    local CameraAngle = CameraCF.LookVector.Y

                    VectorForce.RelativeTo = Enum.ActuatorRelativeTo.Attachment0

                    if CameraAngle < 0 then
                        CameraAngle = CameraAngle * 2
                    else
                        CameraAngle = CameraAngle / 2
                    end

                    local AcumulatedForce = Character:GetAttribute("AcumulatedForce") or 0

                    AcumulatedForce += (if CameraAngle > 0 then CameraAngle * 1 -(Character.HumanoidRootPart.Velocity.Z)  else CameraAngle * 1 + (Character.HumanoidRootPart.Velocity.Z))

                    local Force = Vector3.new(0, 0, BaseForce * CameraAngle)
                    local TotalForce = Force + Vector3.new(0, 0, AcumulatedForce)

                    VectorForce.Force = TotalForce

                    Character:SetAttribute("AcumulatedForce", AcumulatedForce)

                end
            else
                BodyGyro.MaxTorque = Vector3.new(0, 0, 0)
                local Root = Character:FindFirstChild("HumanoidRootPart")
                if not Root then return end
                Root:SetAttribute("AcumulatedForce", Root.Velocity.Z)
            end
        end)

        VectorForce.Force = Vector3.new(0, 0, 0)
        VectorForce.Enabled = true

    end
end

if Player.Character then
    CharacterAdded(Player.Character or Player.CharacterAdded:Wait())
end

Player.CharacterAdded:Connect(CharacterAdded)

return Glider