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
local GenService

local GameUpdate = Net:RemoteEvent("GameUpdate")
local Reset = Net:RemoteEvent("Reset")
local DisplayWinner = Net:RemoteEvent("DisplayWinner")
local CreateCoins = Net:RemoteEvent("CreateCoins")
local ResetRing = Net:RemoteEvent("ResetRing")

local SpawnLocation = workspace.Lobby.SpawnLocation

local Nodes = CollectionService:GetTagged("Node")
local CurrentMatch = nil
local CurrentEndNode = Instance.new("ObjectValue", ReplicatedStorage)

local MatchTime = 280
local Current = 0
local Interval = 1

local TimeLeft = Instance.new("NumberValue")
TimeLeft.Parent = ReplicatedStorage
TimeLeft.Name = "TimeLeft"
TimeLeft.Value = MatchTime

local orderedDatastores = {
    ["MostWins"] = DataStoreService:GetOrderedDataStore("MostWins"),
    ["RecordTime"] = DataStoreService:GetOrderedDataStore("RecordTime")
}

PhysicsService:RegisterCollisionGroup("Participants")
PhysicsService:CollisionGroupSetCollidable("Participants", "Participants", false)

local Game = Knit.CreateService {
    Name = "GameService" ,
    Client = {},
    GameState = Instance.new("StringValue"),
}


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
    local Impact = game.SoundService.SFX.Impact:Clone()
    Impact.Parent = Character.HumanoidRootPart
    if not ActiveCheckpoint then return end
    Character:PivotTo(CFrame.new(ActiveCheckpoint:GetPivot().Position + Vector3.new(0,5,0)))
end


function Game:StartTimer()
    if CurrentMatch then CurrentMatch:Disconnect() end
    self.GameState.Value = "In Progress"

    -- Generate The Map
    GenService:GenerateMap()

    local EndNode = CollectionService:GetTagged("Node")
    for _, Node in EndNode do
        if Node.Name == "End" then
            if Node:GetAttribute("End") then
                CurrentEndNode.Value = Node
            end
        end
    end

    CurrentMatch = RunService.Heartbeat:Connect(function(delta)
        Current = Current + delta
        if Current >= Interval then
            Current = 0
            if TimeLeft.Value > 0 then
                TimeLeft.Value -= 1
            else
                self:EndMatch()
            end
        end
    end)

end

function Game:EndMatch()
    self.GameState.Value = "Ended"
    self.WinnerCount = 0

    TimeLeft.Value = MatchTime
    Reset:FireAllClients()

    print("Match ended!")
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

        self.RegisteredPlayers[Player] = {
            PlayerIcon = PlayerIconClone,
            StartNode = StartNode,
            EndNode = CurrentEndNode,
        }

        for _, Node in Nodes do
            if Node.Name == "Start" then
                StartNode = Node
            end
        end

        local Magnitude = (StartNode.Position - CurrentEndNode.Value.Position).Magnitude

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

            if Character.HumanoidRootPart.Position.Z < CurrentEndNode.Value.Position.Z then
                local CompletedTime = MatchTime - TimeLeft.Value
                local MinimumTime = LeaderboardData.RecordTime.MinimumTime

                if CompletedTime >= MinimumTime then
                    if Humanoid and Humanoid.Health > 0 then
                        local RecordTime = DataService:Get(Player, "RecordTime")

                        self.WinnerCount += 1

                        DisplayWinner:FireAllClients(Player.Name, self.WinnerCount)

                        if CompletedTime < RecordTime then
                            DataService:Set(Player, "RecordTime", CompletedTime)
                        end

                        local leaderstats = Player:FindFirstChild("leaderstats")
                        local Wins = leaderstats:FindFirstChild("Wins")
                        local Coins = leaderstats:FindFirstChild("Coins")
    
                        if not Wins or not Coins then return end
                        
                        local CurrentCoins = DataTypeHandler:StringToNumber(Coins.Value)
                        Coins.Value = DataTypeHandler:NumberToString(CurrentCoins + 200)

                        local CurrentWins = DataTypeHandler:StringToNumber(Wins.Value)
                        Wins.Value = DataTypeHandler:NumberToString(CurrentWins + 1)
    
                        Character:PivotTo(SpawnLocation.CFrame + Vector3.new(0, 5, 0))
                        Reset:FireClient(Player)
                    end
                else
                    Character:PivotTo(SpawnLocation.CFrame + Vector3.new(0, 5, 0))
                    Reset:FireClient(Player)
                    warn("Completed lap too fast!")
                end
            end
        end

        self.RegisteredPlayers[Player].TimeLeft = TimeLeft.Changed:Connect(UpdateIcon)

    end

end

local function canUpdateLeaderboardData(ascending, data1, data2)
    if ascending then
        if data1 >= data2 then return false end -- Data1 must be smaller than data2 to return true, example 100 seconds are less than 200 seconds
    else
        if data1 <= data2 then return false end -- Data1 must be bigger than data2 to return true, example 5 wins are bigger than 3 wins
    end

    return true
end

function Game:RemovePlayer(Player)
	if self.RegisteredPlayers[Player] then
		self.RegisteredPlayers[Player].PlayerIcon:Destroy()
		self.RegisteredPlayers[Player].TimeLeft:Disconnect()
		self.RegisteredPlayers[Player] = nil

        DataService:WipeKey(Player, "FastestTime")

		local data = {
			["RecordTime"] = DataService:GetRemaster(Player, "RecordTime"),
			["MostWins"] = DataService:GetTableKey(Player, "leaderstats", "Wins")
		}

		local leaderboards = CollectionService:GetTagged("Leaderboard")

		for _, leaderboard in leaderboards do
            local datastore = orderedDatastores[leaderboard.Name]

            if not datastore then
                warn("Datastore not found in table.")
                continue
            end
            
			local dataToSetTo = math.abs(tonumber(data[leaderboard.Name])) 
			local leaderboardData = LeaderboardData[leaderboard.Name]
			local entryHolder = leaderboard.LeaderboardGui.EntryHolder
			local ascending = leaderboardData.Ascending
			local finishedLoading = leaderboard:GetAttribute("FinishedLoading") or leaderboard:GetAttributeChangedSignal("FinishedLoading"):Wait()
			local lowestValue = leaderboard:GetAttribute("LowestValue")

			if entryHolder:FindFirstChild(Player.Name) then
				local entryData = entryHolder[Player.Name]:GetAttribute("Data")
				local canUpdate = canUpdateLeaderboardData(ascending, dataToSetTo, entryData)

				if not canUpdate then
					print("You are already on the leaderboard with the same data!", "Data: "..dataToSetTo, "CurrentData: "..entryData)
					continue
				end
			end

			if lowestValue then
				local canUpdate = canUpdateLeaderboardData(ascending, dataToSetTo, lowestValue)
				if not canUpdate then
					print("Your data is lower or equal to the minimum!", "Data: "..dataToSetTo, "Minimum: "..lowestValue)
					continue
				end
			end
			
            local success, errorMessage = pcall(function()
                datastore:SetAsync(Player.UserId, dataToSetTo)
            end)

            if not success then
                warn(errorMessage)
            end

		end
	end
end

function Game:KnitInit()
    self.RegisteredPlayers = {}
end

function Game:KnitStart()
    repeat task.wait() until Knit.FullyStarted

    DataService = Knit.GetService("DataService")
    GenService = Knit.GetService("GenService")

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