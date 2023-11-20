local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = game.Players.LocalPlayer

local Glider = Knit.CreateController {
    Name = "Glider";
    Client = {};
}

local Connection
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

local function CharacterAdded(Character)
    local Humanoid = Character:WaitForChild("Humanoid")
    local humanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if humanoidRootPart then

        local BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(0, 0, 0)
        BodyGyro.P = getMass(Character) * 10000

        BodyGyro.D = 1000
        BodyGyro.Parent = humanoidRootPart

        if Connection then
            Connection:Disconnect()
        end

        Connection = RunService.RenderStepped:Connect(function()
            if Humanoid:GetState() == (Enum.HumanoidStateType.Freefall or Enum.HumanoidStateType.FallingDown) then
                local CameraCF = Camera.CFrame
                BodyGyro.MaxTorque = Vector3.new(4500, 100, 100)
                BodyGyro.CFrame = CameraCF
            else
                BodyGyro.MaxTorque = Vector3.new(0, 0, 0)
            end
        end)

    end
end

if Player.Character then
    CharacterAdded(Player.Character or Player.CharacterAdded:Wait())
end

Player.CharacterAdded:Connect(CharacterAdded)

return Glider