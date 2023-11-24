local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Glider = Knit.CreateController {
    Name = "GliderController";
    Client = {};
}

local BaseForce = 1500
local MaxForce = 10000
local MaxAltitude = 1200
local CooldownTime = 10
local Cooldown = false

local Connections = {}

local Warnings = {
    Height = {
        [1] = "Your altitude is too high, you are going to fall!",
        [2] = "There is no air up there!",
        [3] = "Maximum altitude reached!",
        [4] = "You are about to stall!"
    },

    Death = {
        [1] = "You lost control of your glider and fell to your death!",
        [2] = "Ouch! You fell to your death!",
    }
}

local function getMass(Model)
    local Mass = 0
    for i, Object in Model:GetDescendants() do
        if Object:IsA("BasePart") or Object:IsA("MeshPart") then
            Mass += Object:GetMass()
        end
    end
    return Mass
end

local function GetGlider(Character)
    for _, Accessory in Character:GetChildren() do
        if CollectionService:HasTag(Accessory, "Glider") then
            return Accessory
        end
    end
end

local function GetRandomWarning(Type)
    local Random = math.random(1, #Warnings[Type])
    return Warnings[Type][Random]
end

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

        Connections["Death"] = Humanoid.Died:Connect(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Glider";
                Text = GetRandomWarning("Death");
                Duration = 5;
            })
        end)

        Connections["RunService"] = RunService.RenderStepped:Connect(function(deltaTime)
            if Humanoid:GetState() == (Enum.HumanoidStateType.Freefall or Enum.HumanoidStateType.FallingDown) then
                local Root = Character:FindFirstChild("HumanoidRootPart")
                if not Root then return end

                local CameraCF = Camera.CFrame
                BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                BodyGyro.CFrame = CameraCF

                if not Character:GetAttribute("Boost") or not Character:GetAttribute("Tornado") then
                    VectorForce.RelativeTo = Enum.ActuatorRelativeTo.Attachment0

                    local Velocity = Character.HumanoidRootPart.Velocity
                    local CameraAngle = CameraCF.LookVector.Y
                    local Altitude = Character.HumanoidRootPart.Position.Y
                    local AcumulatedForce = Character:GetAttribute("AcumulatedForce") or 0

                    if CameraAngle < 0 then
                        CameraAngle = CameraAngle * 2
                    else
                        CameraAngle = CameraAngle / 2
                    end

                    AcumulatedForce += (if CameraAngle > 0.1 then CameraAngle * 1 -(Velocity.Z)  else CameraAngle * 1 + (Velocity.Z))

                    if AcumulatedForce > MaxForce then
                        AcumulatedForce = MaxForce
                    end

                    if Altitude >= MaxAltitude then
                        AcumulatedForce -= Character.HumanoidRootPart.Velocity.Z

                        Cooldown = true

                        if not Cooldown then
                            StarterGui:SetCore("SendNotification", {
                                Title = "Glider";
                                Text = GetRandomWarning("Height");
                                Duration = 5;
                            })
                        end

                        task.delay(CooldownTime, function()
                            Cooldown = false
                        end)

                    end

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

Glider.GetGlider = GetGlider

return Glider