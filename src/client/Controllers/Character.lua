local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Shake = require(ReplicatedStorage.Packages.Shake)
local shake = Shake.new()

local Camera = workspace.CurrentCamera
local Player = game.Players.LocalPlayer

local Animations = ReplicatedStorage.Assets.Animations

local CharacterController = Knit.CreateController { Name = "CharacterController" }
local Connection

local RagdollService

local function _Shake()
    local priority = Enum.RenderPriority.Last.Value
    shake.FadeInTime = 0
    shake.Frequency = 0.08
    shake.Amplitude = 3
    shake.RotationInfluence = Vector3.new(0.1, 0.1, 0.1)
    shake:Start()
    shake:BindToRenderStep(Shake.NextRenderName(), priority, function(pos, rot, isDone)
        Camera.CFrame *= CFrame.new(pos) * CFrame.Angles(rot.X, rot.Y, rot.Z)
    end)
end

local function CharacterAdded(character)
    CharacterController:LoadAnimations(character)
    local Humanoid = character:WaitForChild("Humanoid")

    if Connection then
        Connection:Disconnect()
    end

    Connection = Humanoid.Died:Connect(function()
        _Shake()
        RagdollService:CreateRagdoll()
    end)

end

local function CharacterRemoving()
    CharacterController:UnloadAnimations()
end

function CharacterController:KnitStart()
    self.Player = Player
    self.AnimationCache = {}
    self.Connections = {}

    RagdollService = Knit.GetService("RagdollService")
    CharacterAdded(self.Player.Character or self.Player.CharacterAdded:Wait())

    self.Player.CharacterAdded:Connect(CharacterAdded)
    self.Player.CharacterRemoving:Connect(CharacterRemoving)
end

function CharacterController:LoadAnimations(character)
    local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")

    for _, animation in Animations:GetChildren() do
        self.AnimationCache[animation.Name] = animator:LoadAnimation(animation)
    end
end

function CharacterController:UnloadAnimations()
    self.AnimationCache = {}
end

function CharacterController:PlayAnimation(animationName)
    self.AnimationCache[animationName]:Play()
end

function CharacterController:StopAnimation(animationName)
    self.AnimationCache[animationName]:Stop()
end

function CharacterController:ChangeAnimationSpeed(animationName, animationSpeed)
    self.AnimationCache[animationName]:AdjustSpeed(animationSpeed)
end


return CharacterController