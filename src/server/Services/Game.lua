local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local PhysicsService = game:GetService("PhysicsService")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage.Assets
local UI = Assets.UI

local ProgressBar = UI.ProgressBar
local ProgressIcon = UI.ProgressIcon

local PlayerIcon = ProgressIcon.PlayerIcon

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local LeaderboardData = require(ServerScriptService.Server.Services.Data.LeaderboardData)
local DataTypeHandler = require(ReplicatedStorage.Shared.Modules.DataTypeHandler)
local DataService

local GameUpdate = Net:RemoteEvent("GameUpdate")
local Reset = Net:RemoteEvent("Reset")
local DisplayWinner = Net:RemoteEvent("DisplayWinner")

local MatchTime = 480
local Current = 0
local Interval = 1
local RewardAmount = 10

local TimeLeft = Instance.new("NumberValue")
TimeLeft.Parent = ReplicatedStorage

TimeLeft.Name = "TimeLeft"
TimeLeft.Value = MatchTime

PhysicsService:RegisterCollisionGroup("Participants")
PhysicsService:CollisionGroupSetCollidable("Participants", "Participants", false)

local Game = Knit.CreateService {
    Name = "GameService" ,
    Client = {},
    GameState = Instance.new("StringValue"),
}

local Nodes = CollectionService:GetTagged("Node")
local CurrentMatch = nil

local function getMass(Model)
    local Mass = 0
    for i, Object in Model:GetDescendants() do
        if Object:IsA("BasePart") or Object:IsA("MeshPart") then
            Mass += Object:GetMass()
        end
    end
    return Mass
end

local function disableCollisions(character)
    for _, bodyPart in character:GetDescendants() do
        if bodyPart:IsA("BasePart") or bodyPart:IsA("MeshPart") then
            bodyPart.CollisionGroup = "Participants"
        end
    end
end

function Game.Client:Respawn(Player, ActiveCheckpoint)
    Player:LoadCharacter()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    if not ActiveCheckpoint then return end
    Character:PivotTo(CFrame.new(ActiveCheckpoint:GetPivot().Position + Vector3.new(0,5,0)))
end

function Game.Client:CheckpointReached(Player)
    local leaderstats = Player:FindFirstChild("leaderstats")
    if not leaderstats then return end

    local Coins = leaderstats:FindFirstChild("Coins")
    if not Coins then return end

    local CurrentCoins = DataTypeHandler:StringToNumber(Coins.Value)
    local HasDoubleCoin = Player.Bonuses:FindFirstChild("Coins")
    Coins.Value = DataTypeHandler:NumberToString(CurrentCoins + RewardAmount * (HasDoubleCoin and 2 or 1))

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
            end
        end
    end)
end

function Game:EndMatch()
    self.GameState.Value = "Ended"
    self.WinnerCount = 0

    Reset:FireAllClients()
    print("Match Ended")
    self:StartTimer()
end

function Game:RegisterPlayer(Player)
    if not self.RegisteredPlayers[Player] then
        self.RegisteredPlayers[Player] = {}
        
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Humanoid = Character:WaitForChild("Humanoid")
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

        Player.CharacterAdded:Connect(function(character)
            Character = character
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            disableCollisions(Character)
        end)

        disableCollisions(Character)
        
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
            local RawDistance = StartNode.Position - HumanoidRootPart.Position
            local Distance = RawDistance.Magnitude

            local Progress = 1 - (Distance / Magnitude)

            if Distance < 0 then
                Progress = 0
            end

            PlayerIconClone.Position = UDim2.new(1 - Progress, 0, 0.5, 0)
            local DistanceLeft = (StartNode.Position - HumanoidRootPart.Position).Magnitude
            local _Progress = (DistanceLeft / Magnitude)
            Character:SetAttribute("Progress", _Progress)

            local isCharacter = Player.Character
            if not isCharacter then return end

            local isRootPart = isCharacter:FindFirstChild("HumanoidRootPart")
            if not isRootPart then return end

            if Character.HumanoidRootPart.Position.Z < EndNode.Position.Z then
                if Humanoid and Humanoid.Health > 0 then
                    local FastestTime = DataService:Get(Player, "FastestTime")
                    local CompletedTime = MatchTime - TimeLeft.Value
                    local MinimumTime = LeaderboardData.FastestTime.MinimumTime

                    if CompletedTime < MinimumTime then
                        Character:PivotTo(workspace.Maps.Lobby.Props.SpawnLocation.CFrame + Vector3.new(0, 5, 0))
                        Reset:FireClient(Player) 
                        warn("Completed lap too fast!")
                        return 
                    end

                    self.WinnerCount += 1

                    if self.WinnerCount == 1 then
                        Player.Data.WheelSpins.Value += 1
                    end
    
                    DisplayWinner:FireAllClients(Player.Name, self.WinnerCount)
                    
                    if CompletedTime < FastestTime then
                        DataService:Set(Player, "FastestTime", CompletedTime)
                    end
                    
                    local leaderstats = Player:FindFirstChild("leaderstats")
                    local Wins = leaderstats:FindFirstChild("Wins")

                    if not Wins then return end

                    local CurrentWins = DataTypeHandler:StringToNumber(Wins.Value)
                    Wins.Value = DataTypeHandler:NumberToString(CurrentWins + 1)

                    Character:PivotTo(workspace.Maps.Lobby.Props.SpawnLocation.CFrame + Vector3.new(0, 5, 0))
                    Reset:FireClient(Player)
                else
                    Reset:FireClient(Player)
                end
            end
        end

        self.RegisteredPlayers[Player].TimeLeft = TimeLeft.Changed:Connect(UpdateIcon)

    end

end

local function canUpdateLeaderboardData(ascending, data1, data2)
    if ascending then
        print(data1, data2, data1 >= data2)
        if data1 >= data2 then return false end -- Data1 must be smaller than data2 to return true, example 100 seconds are less than 200 seconds
    else
        print(data1, data2, data1 <= data2)
        if data1 <= data2 then return false end -- Data1 must be bigger than data2 to return true, example 5 wins are bigger than 3 wins
    end

    return true
end

function Game:RemovePlayer(Player)
    if self.RegisteredPlayers[Player] then
        self.RegisteredPlayers[Player].PlayerIcon:Destroy()
        self.RegisteredPlayers[Player].TimeLeft:Disconnect()
        self.RegisteredPlayers[Player] = nil

        local data = {
            ["FastestTime"] = DataService:GetRemaster(Player, "FastestTime"),
            ["Wins"] = DataService:GetTableKey(Player, "leaderstats", "Wins")
        }

        local leaderboards = CollectionService:GetTagged("Leaderboard")
        
        for _, leaderboard in leaderboards do            
            local datastore = DataStoreService:GetOrderedDataStore(leaderboard.Name)
            local dataToSetTo = math.abs(tonumber(data[leaderboard.Name])) 
            local leaderboardData = LeaderboardData[leaderboard.Name]
            local entryHolder = leaderboard.LeaderboardGui.EntryHolder
            local ascending = leaderboardData.Ascending
            local minimum

            if entryHolder:FindFirstChild(Player.Name) then
                local entryData = entryHolder[Player.Name]:GetAttribute("Data")

                local canUpdate = canUpdateLeaderboardData(ascending, dataToSetTo, entryData)

                if not canUpdate then continue end
            end

            repeat task.wait() until #entryHolder:GetChildren() >= leaderboardData.Pages -- Waits for all the pages to load before trying to find the minimum

            for _, entry in entryHolder:GetChildren() do
                if entry.ClassName ~= "Frame" or entry.Name == "EntryTemplate" then continue end
        
                local entryData = entry:GetAttribute("Data")
            
                if not minimum then
                    minimum = entryData
                else
                    if ascending then
                        if minimum > entryData then -- Gets the biggest number on the lb, for example the biggest minimum is 200 seconds so your time must be less than 200 seconds
                            continue
                        end
					else
                        if minimum < entryData then -- Gets the smallest number lb, for example your wins need to be greather than 2
                            continue
                        end
                    end
            
                    minimum = entryData
                end
			end
            
            local canUpdate = canUpdateLeaderboardData(ascending, dataToSetTo, minimum)

            if not canUpdate then continue end

            datastore:SetAsync(Player.Name, dataToSetTo)
        end
    end
end

function Game:KnitInit()
    self.RegisteredPlayers = {}
end

function Game:KnitStart()
    repeat task.wait() until Knit.FullyStarted

    DataService = Knit.GetService("DataService")

    self.GameState.Value = "Waiting"
    self.WinnerCount = 0

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