local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Glider = Knit.CreateController {
    Name = "GliderController";
    Client = {};
}

local MaxForce = 10000
local MaxAltitude = 1200
local CooldownTime = 10
local BaseThrottle = -300
local thrustMagnitude = 1500

local UPWARD_ANGLE_THRESHOLD = 0.2
local UPWARD_SPEED_FACTOR = 1
local DOWNWARD_SPEED_FACTOR = 0.01
local DRAG_COEFFICIENT = 0.6
local MAX_FORCE = 1600
local ALTITUDE_MAINTAIN_FORCE = 1500

local AirDensity = 1.225

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

local previousYPosition = nil

local function calculateMaintainYForce(character)
    local currentYPosition = character.HumanoidRootPart.Position.Y
    if previousYPosition and currentYPosition < previousYPosition then
        local mass = getMass(character)
        local gravity = workspace.Gravity
        previousYPosition = currentYPosition
        return mass * gravity + ALTITUDE_MAINTAIN_FORCE
    else
        previousYPosition = currentYPosition
        return 0
    end
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

        local BodyThrust = Instance.new("BodyThrust")
        BodyThrust.Force = Vector3.new(0, 0, 0)
        BodyThrust.Parent = humanoidRootPart

        thrustMagnitude = getMass(Character) * 2500

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

        Connections["RunService"] = RunService.Heartbeat:Connect(function(deltaTime)
            if Humanoid:GetState() == (Enum.HumanoidStateType.Freefall or Enum.HumanoidStateType.FallingDown) then
                local Root = Character:FindFirstChild("HumanoidRootPart")
                if not Root then return end

                local CameraCF = Camera.CFrame
                local GoalCF = CFrame.new()

                BodyGyro.MaxTorque = Vector3.new(10000, 5000, 5000)

                local IsEnoughThrust = Root.Velocity.Magnitude >= thrustMagnitude

                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    GoalCF = GoalCF * CFrame.Angles(0, math.rad(40), math.rad(30))
                    if IsEnoughThrust then
                        BodyThrust.Force = Root.CFrame.LookVector * thrustMagnitude * CFrame.Angles(0, math.rad(60), 0)
                    end
                elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    GoalCF = GoalCF * CFrame.Angles(0, math.rad(-40), math.rad(-30))
                    if IsEnoughThrust then
                        BodyThrust.Force = Root.CFrame.LookVector * -thrustMagnitude * CFrame.Angles(0, math.rad(-60), 0)
                    end
                end

                if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    GoalCF = GoalCF * CFrame.Angles(math.rad(40), 0, 0)
                    if IsEnoughThrust then
                        BodyThrust.Force = Root.CFrame.LookVector * thrustMagnitude * CFrame.Angles(math.rad(60), 0, 0)
                    end
                end

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    GoalCF = GoalCF * CFrame.Angles(math.rad(-20), 0, 0)
                    if IsEnoughThrust then
                        BodyThrust.Force = Root.CFrame.LookVector * -thrustMagnitude
                    end
                end

                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    GoalCF = GoalCF * CFrame.Angles(math.rad(-40), 0, 0)
                    if IsEnoughThrust then
                        BodyThrust.Force = Root.CFrame.LookVector * -thrustMagnitude * CFrame.Angles(math.rad(-60), 0, 0)
                    end
                end

                BodyGyro.CFrame = CameraCF * GoalCF

                if not Character:GetAttribute("Boost") and not Character:GetAttribute("Tornado") then
                    VectorForce.RelativeTo = Enum.ActuatorRelativeTo.Attachment0

                    local CameraAngle = CameraCF.LookVector.Y
                    local Altitude = Character.HumanoidRootPart.Position.Y
                    local AcumulatedForce = Character:GetAttribute("AcumulatedForce") or 0

                    if CameraAngle < 0 then
                        CameraAngle = CameraAngle * 2
                    else
                        CameraAngle = CameraAngle / 2
                    end

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

                    local Mass = getMass(Character)
                    local Weight = Mass * workspace.Gravity
                    local Velocity = Character.HumanoidRootPart.Velocity.Magnitude
                    local DragForceMagnitude = DRAG_COEFFICIENT * AirDensity * Velocity^2
                    local DragForce = Vector3.new(0, 0, -DragForceMagnitude)

                    local Force = Vector3.new(0, Weight, -math.abs(Root.Velocity.Z + AcumulatedForce))
                    local TotalForce = Force + Vector3.new(0, math.abs(Root.Velocity.Y) + Weight, -math.abs(Root.Velocity.Z)) + DragForce

                    local maintainYForce = calculateMaintainYForce(Character)

                    TotalForce = TotalForce + Vector3.new(0, maintainYForce, 0)
                    CameraAngle = math.clamp(CameraAngle, -.5, .5)

                    if CameraAngle > UPWARD_ANGLE_THRESHOLD then
                        TotalForce = TotalForce * Vector3.new(1, UPWARD_SPEED_FACTOR, UPWARD_SPEED_FACTOR)
                        if TotalForce.Y > MaxForce then
                            TotalForce = Vector3.new(TotalForce.X, MaxForce, TotalForce.Z)
                        end
                    elseif CameraAngle < 0 then
                        TotalForce = TotalForce * Vector3.new(1, math.abs(1 + CameraAngle * DOWNWARD_SPEED_FACTOR * 2), 1 + CameraAngle * DOWNWARD_SPEED_FACTOR)
                    else
                        TotalForce = TotalForce * Vector3.new(1, 1, 1)
                    end

                    if TotalForce.Magnitude > MAX_FORCE then
                        TotalForce = TotalForce.Unit * MAX_FORCE + Vector3.new(0, maintainYForce, BaseThrottle)
                    end
  
                    VectorForce.Force = TotalForce
                    Character:SetAttribute("AcumulatedForce", AcumulatedForce)

                end
            else
                BodyGyro.MaxTorque = Vector3.new(0, 0, 0)
                local Root = Character:FindFirstChild("HumanoidRootPart")
                if not Root then return end
                VectorForce.Force = Root.Velocity / 2
                Root:SetAttribute("AcumulatedForce", 0)
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