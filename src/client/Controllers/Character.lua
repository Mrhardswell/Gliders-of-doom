local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Animations = ReplicatedStorage.Assets.Animations

local CharacterController = Knit.CreateController { Name = "CharacterController" }

local function CharacterAdded(character)
    CharacterController:LoadAnimations(character)
end 

local function CharacterRemoving(character)
    CharacterController:UnloadAnimations()
end

function CharacterController:KnitStart()
    self.Player = game:GetService("Players").LocalPlayer
    self.AnimationCache = {}

    task.spawn(CharacterAdded, self.Player.Character or self.Player.CharacterAdded:Wait())

    self.Player.CharacterAdded:Connect(CharacterAdded)
    self.Player.CharacterRemoving:Connect(CharacterRemoving)
end

function CharacterController:LoadAnimations(character)
    print("load")
    local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")

    for _, animation in Animations:GetChildren() do
        self.AnimationCache[animation.Name] = animator:LoadAnimation(animation)
    end
end

function CharacterController:UnloadAnimations()
    print("unload")
    for _, animation in self.AnimationCache do
        animation = nil
    end
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