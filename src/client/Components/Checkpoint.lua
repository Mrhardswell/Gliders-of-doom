local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local ActiveCheckpoint = Instance.new("ObjectValue")
ActiveCheckpoint.Parent = Players.LocalPlayer
ActiveCheckpoint.Name = "ActiveCheckpoint"

local CurrentPosition = Instance.new("Vector3Value")

local Nodes = CollectionService:GetTagged("Node")

local StartNode
local EndNode

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local GameService

local PreviouslyUnlocked = {}

local Checkpoint = Knit.Component.new {
    Tag = "Checkpoint",
}

for _, Node in Nodes do
    if Node.Name == "Start" then
        StartNode = Node
    elseif Node.Name == "End" then
        EndNode = Node
    end
end

function Checkpoint:Construct()
    self.Model = self.Instance
end

function Checkpoint.Start(self)
    self.Position = self.Model:GetPivot().Position
    repeat task.wait() until Knit.FullyStarted
    if not GameService then
        GameService = Knit.GetService("GameService")
    end
end

local Connection
local Interval = 0.5
local Current = 0
local RewardAmount = 10

local function TrackCharacter(Character : Model)
    local Root = Character:WaitForChild("HumanoidRootPart")
    repeat task.wait() until GameService
    if not Root then print("No root") return end
    if Connection then Connection:Disconnect() end

    Connection = RunService.Heartbeat:Connect(function(delta)
        Current += delta
        if Current < Interval then return end
        Current = 0
        CurrentPosition.Value = Root.Position
    end)

    local Humanoid = Character:WaitForChild("Humanoid")
    if not Humanoid then print("No humanoid") return end

    Humanoid.Died:Connect(function()
        if Connection then Connection:Disconnect() end
        task.wait(2)
        GameService:Respawn(ActiveCheckpoint.Value):andThen(function()
            local Character = Player.Character or Player.CharacterAdded:Wait()
            if not ActiveCheckpoint.Value then return
            elseif ActiveCheckpoint.Value == nil then return end
            local isBase = ActiveCheckpoint.Value:FindFirstChild("Base")
            if not isBase then return end
            Character:PivotTo(CFrame.new(ActiveCheckpoint.Value.Base.Position))
        end)
    end)

    ActiveCheckpoint.Changed:Connect(function()
        if not ActiveCheckpoint.Value then return end
        if PreviouslyUnlocked[ActiveCheckpoint.Value] then return end
        PreviouslyUnlocked[ActiveCheckpoint.Value] = true

        local Active = ActiveCheckpoint.Value
        SoundService.SFX.Checkpoint:Play()

        GameService:CheckpointReached():andThen(function(_RewardAmount)
            RewardAmount = _RewardAmount
        end):await()

        StarterGui:SetCore("SendNotification", {
            Title = "Checkpoint";
            Text = string.format("Checkpoint reached, earned %s coins", tostring(RewardAmount));
            Duration = 2;
        })

    end)

end

local ClosestCheckpoint

CurrentPosition.Changed:Connect(function()
    local Position = CurrentPosition.Value
    
    local ClosestDistance = math.huge
    local Checkpoints = Checkpoint:GetAll()

    for _, Checkpoint in Checkpoints do
        local isBehindCharacter = -Position.Z >= -Checkpoint.Position.Z
        if not isBehindCharacter then continue end
        local Magnitude = (Position - Checkpoint.Position).Magnitude
        if Magnitude < ClosestDistance then
            ClosestCheckpoint = Checkpoint
            ClosestDistance = Magnitude
        end
    end

    if ClosestCheckpoint then
        ActiveCheckpoint.Value = ClosestCheckpoint.Instance
        local Active = ClosestCheckpoint.Model:FindFirstChild("Active")
        local Inactive = ClosestCheckpoint.Model:FindFirstChild("Inactive")
        if Active and Inactive then
            Active.Transparency = 0
            Inactive.Transparency = 1
        end
    end

end)

local function Reset()
    ActiveCheckpoint.Value = nil
    PreviouslyUnlocked = {}
    for _, Checkpoint in Checkpoint:GetAll() do
        local Active = Checkpoint.Model:FindFirstChild("Active")
        local Inactive = Checkpoint.Model:FindFirstChild("Inactive")
        if Active and Inactive then
            Active.Transparency = 0
            Inactive.Transparency = 1
        end
    end
    GameService:Respawn()
end

Player.CharacterAdded:Connect(TrackCharacter)
task.spawn(TrackCharacter, Character)
Net:Connect("Reset", Reset)

return Checkpoint