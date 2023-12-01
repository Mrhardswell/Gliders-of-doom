local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ShopService

local Glider = Knit.CreateController {
    Name = "GliderController";
    Client = {};
}

local MaxForce = 10000
local MaxAltitude = 1200
local CooldownTime = 10
local BaseThrottle = -300
local thrustMagnitude = 200

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
    repeat task.wait() until Character:FindFirstChild("Humanoid")
    return ShopService:EquipLastGlider(Character)
end

local function GetRandomWarning(Type)
    local Random = math.random(1, #Warnings[Type])
    return Warnings[Type][Random]
end

local CurrentConnection = nil

local function Cleanup()
    if CurrentConnection then
        CurrentConnection:Disconnect()
        CurrentConnection = nil
    end
end

local function CharacterAdded(Character)
    local Humanoid = Character:WaitForChild("Humanoid")
    local humanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if humanoidRootPart then
        local LastGlider = nil
        local CurrentGlider = nil

        local BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(0, 0, 0)
        BodyGyro.P = getMass(Character) * 10000

        local BodyThrust = Instance.new("BodyThrust")
        BodyThrust.Force = Vector3.new(0, 0, 0)
        BodyThrust.Parent = humanoidRootPart

        BodyGyro.D = 1000
        BodyGyro.Parent = humanoidRootPart

        local function Equipped()
            for Name, Connection in Connections do
                Connection:Disconnect()
                Connections[Name] = nil
            end

            local _Glider

            if LastGlider then
                for _, Child in Character:GetChildren() do
                    if CollectionService:HasTag(Child, "Glider") then
                        if Child == LastGlider then
                            _Glider = Child
                        end
                    end
                end
            end

            if not _Glider then
                ShopService:EquipLastGlider(Character):andThen(function(data)
                    _Glider = data

                end):await()
            end

            LastGlider = _Glider

            local Boost = _Glider:WaitForChild("Handle"):WaitForChild("Boost")
            local VectorForce = Boost:WaitForChild("VectorForce")

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

                    BodyGyro.MaxTorque = Vector3.new(math.huge, 5000, 5000)

                    thrustMagnitude = getMass(Character)

                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        GoalCF = GoalCF * CFrame.Angles(0, math.rad(40), math.rad(30))
                        BodyThrust.Force = -CameraCF.RightVector * thrustMagnitude * 2
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        GoalCF = GoalCF * CFrame.Angles(0, math.rad(-40), math.rad(-30))
                        BodyThrust.Force = CameraCF.RightVector * thrustMagnitude * 2
                    end

                    if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        GoalCF = GoalCF * CFrame.Angles(math.rad(60), 0, 0)
                        BodyThrust.Force = (CameraCF.UpVector + CameraCF.LookVector) * thrustMagnitude * 2
                    end

                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        GoalCF = GoalCF * CFrame.Angles(math.rad(-10), 0, 0)
                        BodyThrust.Force = CameraCF.LookVector * thrustMagnitude
                    end

                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        GoalCF = GoalCF * CFrame.Angles(math.rad(-60), 0, 0)
                        BodyThrust.Force = (-CameraCF.UpVector + CameraCF.LookVector) * thrustMagnitude * 2
                    end

                    BodyGyro.CFrame = BodyGyro.CFrame:Lerp(CameraCF * GoalCF, deltaTime * 10)

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

                        if TotalForce.Magnitude < 200 then
                            VectorForce.Force = TotalForce
                        else
                            VectorForce.Force = TotalForce * 0.75
                        end

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

        if CurrentConnection then
            Cleanup()
        end


        CurrentConnection = Equipped()

        Character.ChildAdded:Connect(function(Child)
            if Child == LastGlider then return end
            if Child:IsA("Accessory") and CollectionService:HasTag(Child, "Glider") then
                if CurrentConnection then
                    Cleanup()
                end
                CurrentConnection = Equipped()
            end
        end)

    end
end

function Glider:KnitStart()
    ShopService = Knit.GetService("ShopService")
    task.spawn(CharacterAdded,Player.Character or Player.CharacterAdded:Wait())
    Player.CharacterAdded:Connect(CharacterAdded)
    Glider.GetGlider = GetGlider
end

return Glider