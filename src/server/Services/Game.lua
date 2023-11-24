local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage.Assets
local UI = Assets.UI

local ProgressBar = UI.ProgressBar
local ProgressIcon = UI.ProgressIcon

local PlayerIcon = ProgressIcon.PlayerIcon

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local DataTypeHandler = require(ReplicatedStorage.Shared.Modules.DataTypeHandler)

local GameUpdate = Net:RemoteEvent("GameUpdate")
local Reset = Net:RemoteEvent("Reset")

local MatchTime = 360
local Current = 0
local Interval = 1
local RewardAmount = 10

local TimeLeft = Instance.new("NumberValue",ReplicatedStorage)
TimeLeft.Name = "TimeLeft"
TimeLeft.Value = MatchTime

local Game = Knit.CreateService {
    Name = "GameService" ,
    Client = {},
    GameState = Instance.new("StringValue"),
}

local Nodes = CollectionService:GetTagged("Node")
local CurrentMatch = nil

function Game.Client:Respawn(Player)
    Player:LoadCharacter()
end

function Game.Client:CheckpointReached(Player)
    local leaderstats = Player:FindFirstChild("leaderstats")
    if not leaderstats then return end

    local Coins = leaderstats:FindFirstChild("Coins")
    if not Coins then return end

    local CurrentCoins = DataTypeHandler:StringToNumber(Coins.Value)
    Coins.Value = DataTypeHandler:NumberToString(CurrentCoins + RewardAmount)

    return RewardAmount
end

function Game:StartTimer()
    if CurrentMatch then CurrentMatch:Disconnect() end
    self.GameState.Value = "In Progress"

    CurrentMatch = RunService.Heartbeat:Connect(function(delta)
        Current = Current + delta
        if Current >= Interval then
            Current = 0
            if TimeLeft.Value > 0 then
                TimeLeft.Value = TimeLeft.Value - 1
            else
                self:EndMatch()
                TimeLeft.Value = MatchTime
                CurrentMatch:Disconnect()
            end
        end
    end)

end

function Game:EndMatch()
    self.GameState.Value = "Ended"
    Reset:FireAllClients()
    self:StartTimer()
end

function Game:RegisterPlayer(Player)
    if not self.RegisteredPlayers[Player] then
        self.RegisteredPlayers[Player] = {}
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

        Player.CharacterAdded:Connect(function(character)
            Character = character
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        end)

        local PlayerIconClone = PlayerIcon:Clone()
        PlayerIconClone.Parent = ProgressBar
        PlayerIconClone.Name = Player.Name

        local userId = Player.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        local content = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

        PlayerIconClone.Image = content
        PlayerIconClone.Size = UDim2.new(0, 35, 0, 35)

        local StartNode
        local EndNode

        self.RegisteredPlayers[Player] = {
            PlayerIcon = PlayerIconClone,
            StartNode = StartNode,
            EndNode = EndNode
        }

        for _, Node in Nodes do
            if Node.Name == "Start" then
                StartNode = Node
            elseif Node.Name == "End" then
                EndNode = Node
            end
        end

        local Magnitude = (StartNode.Position - EndNode.Position).Magnitude

        local function UpdateIcon()
            local Distance = (StartNode.Position - HumanoidRootPart.Position).Magnitude
            local Progress = 1 - (Distance / Magnitude)
            PlayerIconClone.Position = UDim2.new(math.clamp(1 - Progress, 0 , 1), 0, 0.5, 0)
        end

        self.RegisteredPlayers[Player].Timeleft = TimeLeft.Changed:Connect(UpdateIcon)
        print("Registered Player and added to UI: " .. Player.Name)

    end

end

function Game:RemovePlayer(Player)
    if self.RegisteredPlayers[Player] then
        self.RegisteredPlayers[Player].PlayerIcon:Destroy()
        self.RegisteredPlayers[Player].Timeleft:Disconnect()
        self.RegisteredPlayers[Player] = nil
    end
    print("Removed Player: " .. Player.Name)
end

function Game:KnitInit()
    self.RegisteredPlayers = {}
end

function Game:KnitStart()
    self.GameState.Value = "Waiting"

    for _, Player in Players:GetPlayers() do
        self:RegisterPlayer(Player)
    end

    Players.PlayerAdded:Connect(function(Player)
        self:RegisterPlayer(Player)
    end)

    Players.PlayerRemoving:Connect(function(Player)
        self:RemovePlayer(Player)
    end)

    self:StartTimer()
end

return Game