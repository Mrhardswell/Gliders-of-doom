local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local PlayerGui = Player.PlayerGui

local Knit = require(ReplicatedStorage.Packages.Knit)
local Input = require(ReplicatedStorage.Packages.Input)
local Warnings = require(script.Warnings)

local Keyboard = Input.Keyboard
local Gamepad = Input.Gamepad

local Gamepad1 = Gamepad.new(Enum.UserInputType.Gamepad1)

local LastInputDevice = nil
UserInputService.LastInputTypeChanged:Connect(function()
    LastInputDevice = UserInputService:GetLastInputType()
end)

local ShopService

local Glider = Knit.CreateController {
    Name = "GliderController";
    Client = {};
}

local Mobile = PlayerGui:WaitForChild("Mobile")
local MobileControls = Mobile.Main.Controls

local MaxForce = 500
local BaseThrottle = -300
local thrustMagnitude = 200

local UPWARD_ANGLE_THRESHOLD = 0.2
local UPWARD_SPEED_FACTOR = 0.8 -- The higher the value, the faster the player will go up
local DOWNWARD_SPEED_FACTOR = 1
local DRAG_COEFFICIENT = 1 
local MAX_FORCE = 2000 -- In Newtons

local AirDensity = 1.225 -- In kg/m^3

local Connections = {}
local previousYPosition = nil
local CurrentConnection = nil

local function getMass(Model)
    local Mass = 0
    for i, Object in Model:GetDescendants() do
        if Object:IsA("BasePart") or Object:IsA("MeshPart") then
            Mass += Object:GetMass()
        end
    end
    return Mass
end

local function Cleanup()
    if CurrentConnection then
        CurrentConnection:Disconnect()
        CurrentConnection = nil
    end
end

local function calculateMaintainYForce(character)
    local currentYPosition = character.HumanoidRootPart.Position.Y
    if previousYPosition and currentYPosition < previousYPosition then
        local mass = getMass(character)
        local gravity = workspace.Gravity
        previousYPosition = currentYPosition
        return mass * gravity * 1.5
    else
        previousYPosition = currentYPosition
        return 0
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
        local LastGlider = nil
        local LastTrail = nil

        if humanoidRootPart:FindFirstChild("BodyGyro") then
            humanoidRootPart.BodyGyro:Destroy()
        end

        if humanoidRootPart:FindFirstChild("BodyThrust") then
            humanoidRootPart.BodyThrust:Destroy()
        end

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
            local _Trail

            if LastGlider then
                for _, Child in Character:GetChildren() do
                    if CollectionService:HasTag(Child, "Glider") then
                        if Child == LastGlider then
                            _Glider = Child
                        end
                    end
                end
            end

            if LastTrail then
                for _, Child in Character:GetChildren() do
                    if CollectionService:HasTag(Child, "Trail") then
                        if Child == LastTrail then
                            _Trail = Child
                        end
                    end
                end
            end

            if not _Glider then
                ShopService:EquipLastItem("Gliders"):andThen(function(data)
                    _Glider = data
                end):await()
            end

            if not _Trail then
                ShopService:EquipLastItem("Trails"):andThen(function(data)
                    _Trail = data
                end):await()
            end

            LastGlider = _Glider
            LastTrail = _Trail

            local Boost = _Glider:WaitForChild("Handle"):WaitForChild("Boost")
            local VectorForce = Boost:WaitForChild("VectorForce")

            -- Main Connections
            Connections["Death"] = Humanoid.Died:Connect(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Glider";
                    Text = GetRandomWarning("Death");
                    Duration = 5;
                })
            end)

            Connections["RunService"] = RunService.Heartbeat:Connect(function(deltaTime)
                local State = Humanoid:GetState()

                if State == (Enum.HumanoidStateType.Freefall or Enum.HumanoidStateType.FallingDown) then

                    local Root = Character:FindFirstChild("HumanoidRootPart")
                    if not Root then return end

                    local CameraCF = Camera.CFrame
                    local GoalCF = CFrame.new()

                    thrustMagnitude = getMass(Character)

                    BodyGyro.MaxTorque = Vector3.new(math.huge, 300, 500)

                    -- Keyboard Inputs
                    local Forward = Keyboard:IsKeyDown(Enum.KeyCode.W) or Keyboard:IsKeyDown(Enum.KeyCode.Up) or MobileControls.Up:GetAttribute("Pressed")
                    local Right = Keyboard:IsKeyDown(Enum.KeyCode.D) or Keyboard:IsKeyDown(Enum.KeyCode.Right) or MobileControls.Right:GetAttribute("Pressed")
                    local Left = Keyboard:IsKeyDown(Enum.KeyCode.A) or Keyboard:IsKeyDown(Enum.KeyCode.Left) or MobileControls.Left:GetAttribute("Pressed")
                    local Backward = Keyboard:IsKeyDown(Enum.KeyCode.S) or Keyboard:IsKeyDown(Enum.KeyCode.Down) or MobileControls.Down:GetAttribute("Pressed")

                    local Climb = Keyboard:IsKeyDown(Enum.KeyCode.Space)
                    local Dive = Keyboard:IsKeyDown(Enum.KeyCode.LeftControl)

                    -- Controller Inputs
                    if Gamepad1:IsConnected() and LastInputDevice == Enum.UserInputType.Gamepad1 then
                        local Thumbstick1 = Gamepad1:GetThumbstick(Enum.KeyCode.Thumbstick1, 0.2)
                        Left = Thumbstick1.X < -0.2
                        Right = Thumbstick1.X > 0.2
                        Forward = Thumbstick1.Y > 0.2
                        Backward = Thumbstick1.Y < -0.2
                        Climb = Gamepad1:IsButtonDown(Enum.KeyCode.ButtonA)
                        Dive = Gamepad1:IsButtonDown(Enum.KeyCode.ButtonB)
                    end

                    local Modifier = thrustMagnitude * Root.Velocity.Magnitude / 2000

                    -- States
                    if Forward or Backward then
                        GoalCF = GoalCF * CFrame.Angles(math.rad(-5), 0, 0)
                        if not Root:GetAttribute("Boost") then
                            BodyThrust.Force = CameraCF.LookVector * Modifier
                        end
                    end

                    if Climb then
                        GoalCF = GoalCF * CFrame.Angles(math.rad(40), 0, 0)
                        if not Root:GetAttribute("Boost") then
                            BodyThrust.Force = CameraCF.UpVector * math.clamp((Modifier*2)^4, 0, MAX_FORCE)
                        end
                    end

                    if Dive then
                        GoalCF = GoalCF * CFrame.Angles(math.rad(-40), 0, 0)
                        if not Root:GetAttribute("Boost") then
                            BodyThrust.Force = -CameraCF.UpVector * math.clamp((Modifier*2)^4, 0, MAX_FORCE)
                        end
                    end

                    if Right then
                        GoalCF = GoalCF * CFrame.Angles(0, math.rad(-40), math.rad(-30))
                        if not Root:GetAttribute("Boost") then
                            BodyThrust.Force = CameraCF.LookVector * math.clamp((Modifier*2)^4, 0, MAX_FORCE)
                        end
                    end

                    if Left then
                        GoalCF = GoalCF * CFrame.Angles(0, math.rad(40), math.rad(30))
                        if not Root:GetAttribute("Boost") then
                            BodyThrust.Force = CameraCF.LookVector * math.clamp((Modifier*2)^4, 0, MAX_FORCE)
                        end
                    end

                    if not Forward and not Backward and not Climb and not Dive and not Right and not Left then
                        BodyThrust.Force = Vector3.new(0, 0, 0)
                    end

                    BodyGyro.CFrame = BodyGyro.CFrame:Lerp(CameraCF * GoalCF, deltaTime * 10)

                    if not Character:GetAttribute("Boost") then
                        VectorForce.RelativeTo = Enum.ActuatorRelativeTo.Attachment0

                        local CameraAngle = CameraCF.LookVector.Y
                        local AcumulatedForce = Character:GetAttribute("AcumulatedForce") or 0

                        if CameraAngle < 0 then
                            CameraAngle = CameraAngle * 2
                        else
                            CameraAngle = CameraAngle / 2
                        end

                        if AcumulatedForce > MaxForce then
                            AcumulatedForce = MaxForce
                        end

                        local Mass = getMass(Character)
                        local Weight = Mass * workspace.Gravity

                        local Velocity = Character.HumanoidRootPart.Velocity.Magnitude
                        local DragForceMagnitude = DRAG_COEFFICIENT * AirDensity * Velocity^2
                        local DragForce = Vector3.new(0, 0, -math.clamp(DragForceMagnitude, 0, 2000))* 120

                        local Force = Vector3.new(0, Weight, Root.Velocity.Z + AcumulatedForce)
                        local TotalForce = Force + Vector3.new(0, math.abs(Root.Velocity.Y) + Weight, 0) + DragForce / 10
                        local maintainYForce = calculateMaintainYForce(Character)

                        TotalForce = TotalForce + Vector3.new(0, maintainYForce/2, 0)
                        CameraAngle = math.clamp(CameraAngle, -.5, .5)

                        if CameraAngle > UPWARD_ANGLE_THRESHOLD then
                            TotalForce = TotalForce * Vector3.new(1, UPWARD_SPEED_FACTOR, UPWARD_SPEED_FACTOR)
                            if TotalForce.Y > MaxForce then
                                TotalForce = Vector3.new(TotalForce.X, MaxForce, TotalForce.Z)
                            end
                        elseif CameraAngle < -UPWARD_ANGLE_THRESHOLD then
                            TotalForce = TotalForce * Vector3.new(1, math.abs(1 + CameraAngle * DOWNWARD_SPEED_FACTOR * 2), 1 + CameraAngle)
                        end

                        if TotalForce.Magnitude > MAX_FORCE then
                            TotalForce = TotalForce.Unit * MAX_FORCE + Vector3.new(0, maintainYForce, BaseThrottle)
                        end

                        VectorForce.Force = TotalForce

                        Character:SetAttribute("AcumulatedForce", AcumulatedForce/1000)

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
            if Child == LastGlider or Child == LastTrail then return end
            if Child:IsA("Accessory") and CollectionService:HasTag(Child, "Glider") or CollectionService:HasTag(Child, "Trail") then
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
    task.spawn(CharacterAdded, Player.Character or Player.CharacterAdded:Wait())
    Player.CharacterAdded:Connect(CharacterAdded)
end


function Glider:GetGlider(Character)
    repeat task.wait() until Character:FindFirstChild("Humanoid")
    return ShopService:EquipLastItem("Gliders")
end

return Glider