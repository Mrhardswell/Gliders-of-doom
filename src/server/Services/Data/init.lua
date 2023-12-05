local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local DataStructure = require(ServerStorage.Private.Archive.DataStructure)
local ProfileService = require(script.ProfileService)

local UpdateClient = Net:RemoteEvent("UpdateClient")

local DataCache = {}

local DataService = Knit.CreateService {
	Name = "DataService";
	Client = {};
	DataCache = DataCache;
}

local DataStore = ProfileService.GetProfileStore("Test2", DataStructure)

function DataService.Client:GetInitialData(Player)
	repeat task.wait() until DataCache[Player]
	return DataCache[Player].Data
end

local function CreateValues(Data, Player)
	print(Data)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

	local Gliders = Instance.new("Folder")
	Gliders.Name = "Gliders"
	Gliders.Parent = Player

	local Trails = Instance.new("Folder")
	Trails.Name = "Trails"
	Trails.Parent = Player

	local SpinTime = Instance.new("StringValue")
	SpinTime.Name = "SpinTime"
	SpinTime.Parent = Player

	if Data["leaderstats"] then
		for Name, Value in pairs(Data["leaderstats"]) do
			local item = Instance.new("StringValue")
			item.Name = Name
			item.Parent = leaderstats
			item.Value = Value
			item.Changed:Connect(function()
				DataCache[Player].Data["leaderstats"][Name] = item.Value
			end)
		end
	end

	if Data["Spins"] then
		local Spins = Instance.new("NumberValue")
		Spins.Name = "Spins"
		Spins.Parent = Player
		Spins.Value = Data["Spins"]
		Spins.Changed:Connect(function()
			DataCache[Player].Data["Spins"] = Spins.Value
		end)
	end

	if Data["TotalPlaytime"] then
		local TotalPlaytime = Instance.new("NumberValue")
		TotalPlaytime.Name = "TotalPlaytime"
		TotalPlaytime.Parent = Player
		TotalPlaytime.Value = Data["TotalPlaytime"]
		TotalPlaytime.Changed:Connect(function()
			if DataCache[Player] == nil then return end
			DataCache[Player].Data["TotalPlaytime"] = TotalPlaytime.Value
		end)
	end

	if Data["Gliders"] then

		Gliders.Changed:Connect(function()
			local gliderData = {}
			for _, Glider in Gliders:GetChildren() do
				gliderData[Glider.Name] = Glider.Value
			end
			DataCache[Player].Data["Gliders"] = gliderData
		end)

		for Index, Glider in Data["Gliders"] do
			local glider = Instance.new("BoolValue")
			glider.Name = Index
			glider.Parent = Gliders
			glider.Value = Glider
			glider.Changed:Connect(function()
				DataCache[Player].Data["Gliders"][Index] = glider.Value
			end)
		end

	end

	if Data["Trails"] then

		Trails.Changed:Connect(function()
			local gliderData = {}
			for _, Glider in Trails:GetChildren() do
				gliderData[Glider.Name] = Glider.Value
			end
			DataCache[Player].Data["Trails"] = gliderData
		end)

		for Index, Glider in Data["Trails"] do
			local glider = Instance.new("BoolValue")
			glider.Name = Index
			glider.Parent = Trails
			glider.Value = Glider
			glider.Changed:Connect(function()
				DataCache[Player].Data["Trails"][Index] = glider.Value
			end)
		end

	end

	if Data["LastGlider"] then
		local LastGlider = Instance.new("StringValue")
		LastGlider.Name = "LastGlider"
		LastGlider.Parent = Player
		LastGlider.Value = Data["LastGlider"]
		LastGlider.Changed:Connect(function()
			DataCache[Player].Data["LastGlider"] = LastGlider.Value
		end)
	end

	if Data["LastTrail"] then
		local LastTrail = Instance.new("StringValue")
		LastTrail.Name = "LastTrail"
		LastTrail.Parent = Player
		LastTrail.Value = Data["LastTrail"]
		LastTrail.Changed:Connect(function()
			DataCache[Player].Data["LastTrail"] = LastTrail.Value
		end)
	end

	if Data["Settings"] then
		for Index, Value in Data["Settings"] do
			Player:SetAttribute(Index, Value)
			Player:GetAttributeChangedSignal(Index):Connect(function()
				DataCache[Player].Data["Settings"][Index] = Player:GetAttribute(Index)
			end)
		end
	end

end

local function PlayerAdded(player : Player)
	if DataCache[player] then return end
	local profile = DataStore:LoadProfileAsync("Player_" .. player.UserId, "ForceLoad")

	if profile then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		-- Check if the player is in the game
		local Players = game:GetService("Players"):GetPlayers()

		if table.find(Players, player) then
			DataCache[player] = profile
			CreateValues(profile.Data, player)
			player:SetAttribute("Ready", true)
			UpdateClient:FireClient(player, DataCache[player].Data)
		else
			print("Player is not in the Game, Releasing Profile")
			profile:Release()
		end

	else
		player:Kick("Unable to Load Saved data. Please Rejoin the game, if this issue persists please contact a developer")
	end
	player:LoadCharacter()
end

local function PlayerRemoved(Player)
	local profile = DataCache[Player]
	if profile ~= nil then
		profile:Release()
		print("Released Profile for", Player.Name, "Data Saved")
	end
end

local function GetData(Player)
	return DataCache[Player]
end

function DataService:KnitInit()
	Players.PlayerAdded:Connect(PlayerAdded)
	Players.PlayerRemoving:Connect(PlayerRemoved)

	for _, Player in Players:GetPlayers() do
		PlayerAdded(Player)
	end
end

function DataService:Gain(Player, Key, value)
	local Value = tostring(value)

	local PlayerData = GetData(Player)
	local Leaderstats = Player:FindFirstChild("leaderstats")

	assert(PlayerData.Data[Key], string.format("Key %s does not exist", Key))

	local _Value = Value
	local Base = tonumber(PlayerData.Data[Key])

	PlayerData.Data[Key] = tostring(Base + _Value)
	Leaderstats[Key].Value = PlayerData.Data[Key]

	return true
end

function DataService.Client:Get(Player, Key, TargetFolder)
	local PlayerData = GetData(Player)
	repeat task.wait() 
		PlayerData = GetData(Player)
	until PlayerData

	assert(PlayerData.Data[Key], string.format("Key %s does not exist", Key))

	local Data = PlayerData.Data[Key] or error(string.format("Key %s does not exist", Key))

	if Key == "Settings" then
		for Index,Value in Data do
			Player:SetAttribute(Index,Value)
		end
	end

	return PlayerData.Data[Key]
end

function DataService:GetPlayerData(Player)
	local PlayerData = GetData(Player)
	repeat task.wait() until PlayerData
	return PlayerData.Data
end

function DataService:WaitForData(player)
	repeat task.wait() until DataCache[player] ~= nil or player:IsDescendantOf(Players) == false

	local LeftServer = not player:IsDescendantOf(Players)

	if LeftServer then
		warn("Player Left Server while waiting for Data")
		return false
	end
	return DataCache[player]
end

function DataService:AddtoTable(Player, Key, Value)
	local PlayerData = GetData(Player)
	assert(PlayerData.Data[Key], string.format("Key %s does not exist", Key))
	if table.find(PlayerData.Data[Key], Value) then
		table.remove(PlayerData.Data[Key], Value)
	end
	table.insert(PlayerData.Data[Key], Value)
	return true
end

function DataService:Get(Player, Key)
	repeat task.wait() until DataCache[Player]
	local PlayerData = DataCache[Player]
	repeat task.wait() until PlayerData.Data
	if not PlayerData.Data[Key] then
		warn(string.format("Key %s does not exist", Key))
		return
	end
	local Data = PlayerData.Data[Key] or error(string.format("Key %s does not exist", Key))
	return Data
end

function DataService:GetRemaster(Player, Key)
	local PlayerData = GetData(Player)

	if PlayerData.Data[Key] ~= nil then
		return  PlayerData.Data[Key]
	end
end

function DataService:Set(Player, Key, Value)
	local PlayerData = GetData(Player)

	if PlayerData.Data[Key] ~= nil then
		if typeof(PlayerData.Data[Key]) == typeof(Value) then
			PlayerData.Data[Key] = Value
		end
	end
end
function DataService:Update(Player, Key, Callback)
	local PlayerData = GetData(Player)
	repeat task.wait() until PlayerData

	local OldData = DataService.Get(Player, Key) 
	local NewData = Callback(OldData)

	DataService:Set(Player, Key, NewData)
end

function DataService:GetTableKey(Player, Table, Key)
	local PlayerData = GetData(Player)

	if PlayerData.Data[Table] ~= nil then
		if PlayerData.Data[Table][Key] ~= nil then
			return	PlayerData.Data[Table][Key]
		end
	end
end


function DataService:AddItem(Player, ID, ItemType)
	print(ID, ItemType)
	local ItemsFolder = Player:FindFirstChild(ItemType)
	local Item = ReplicatedStorage.Assets[ItemType][ID]

	if ItemsFolder and Item then
		local ItemValue = Instance.new("BoolValue")

		ItemValue.Name = ID
		ItemValue.Parent = ItemsFolder
		ItemValue.Value = true

		self:SaveItemData(Player, ItemType)

		return true
	else
		return false
	end
end	

function DataService:GetItemData(Player, ItemType)
	local ItemsFolder = Player:FindFirstChild(ItemType)

	if ItemsFolder then
		local ItemData = {}

		for _, Item in ItemsFolder:GetChildren() do
			ItemData[Item.Name] = Item.Value
		end
		
		return ItemData
	end
end

function DataService:SaveItemData(Player, ItemType)
	local ItemsFolder = Player:FindFirstChild(ItemType)

	if ItemsFolder then
		local ItemData = {}
		local PlayerData = GetData(Player)

		for _, Item in ItemsFolder:GetChildren() do
			ItemData[Item.Name] = Item.Value
		end
		print(ItemData)

		PlayerData.Data[ItemType] = ItemData

		return true
	end
end	

function DataService:AddGlider(Player, ID)
	local Gliders = Player:FindFirstChild("Gliders")
	local Glider = ReplicatedStorage.Assets.Gliders[ID]
	if Gliders and Glider then
		local GliderValue = Instance.new("BoolValue")
		GliderValue.Name = ID
		GliderValue.Parent = Gliders
		GliderValue.Value = true
		self:SaveGliderData(Player)
		return true
	else
		return false
	end
end

function DataService:SetTable(Player, Key, Table)
	local PlayerData = GetData(Player)
	repeat task.wait() until PlayerData
	PlayerData.Data[Key] = Table
	return true
end

local ExposedData = {
	["Settings"] = true;
}

function DataService.Client:RequestSet(Player, Key: string, Value)
	if ExposedData[Key] then
		local PlayerData = GetData(Player)
		assert(PlayerData.Data[Key], string.format("Key %s does not exist", Key))
		assert(type(PlayerData.Data[Key]) == type(Value), string.format("Key %s is not of type %s", Key, type(Value)))
		PlayerData.Data[Key] = Value

		for Index,value in Value do
			Player:SetAttribute(Index,value)
		end
		return {Success = true, Message = "Succesfully saved data"}
	else
		return {Success = false, Message = "Access Denied"}
	end
end

function DataService:GetGliderData(Player)
	local Gliders = Player:FindFirstChild("Gliders")
	if Gliders then
		local GliderData = {}
		for _, Glider in Gliders:GetChildren() do
			GliderData[Glider.Name] = Glider.Value
		end
		return GliderData
	end
end

function DataService:SaveGliderData(Player)
	local Gliders = Player:FindFirstChild("Gliders")
	if Gliders then
		local GliderData = {}
		for _, Glider in Gliders:GetChildren() do
			GliderData[Glider.Name] = Glider.Value
		end
		local PlayerData = GetData(Player)
		PlayerData.Data["Gliders"] = GliderData
		return true
	end
end

function DataService:UpdatePlayerData(Player, Key, Value)
	local PlayerData = GetData(Player)
	repeat task.wait() until PlayerData
	PlayerData.Data[Key] = Value
	return true
end

local Current = 0
local Interval = 1

RunService.Heartbeat:Connect(function(delta)
	Current += delta
	if Current < Interval then return end
	Current = 0
	for _, Player in Players:GetPlayers() do
		local TotalPlaytime = Player:FindFirstChild("TotalPlaytime")
		if TotalPlaytime then
			TotalPlaytime.Value += 1
		end
	end
end)

return DataService
