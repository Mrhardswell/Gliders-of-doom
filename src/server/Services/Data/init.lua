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

local DataStore = ProfileService.GetProfileStore("Test1", DataStructure)

function DataService.Client:GetInitialData(Player)
	repeat task.wait() until DataCache[Player]
	return DataCache[Player].Data
end

local function CreateValues(Data, Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

	local Inventory = Instance.new("Folder")
	Inventory.Name = "Inventory"
	Inventory.Parent = Player
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

	if Data["Inventory"] then
		Inventory.Changed:Connect(function()
			local inventoryData = {}
			for _, Item in Inventory:GetChildren() do
				inventoryData[Item.Name] = Item.Value
			end
			DataCache[Player].Data["Inventory"] = inventoryData
		end)

		for Index, Item in Data["Inventory"] do
			local item = Instance.new("BoolValue")
			item.Name = Index
			item.Parent = Inventory
			item.Value = Item
			item.Changed:Connect(function()
				DataCache[Player].Data["Inventory"][Index] = item.Value
			end)
		end
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

		profile:ListenToRelease(function()
			DataCache[player] = nil
			player:Kick("Profile was relased unexpectedly, data saved, please rejoin the game, if this issue persists please contact the developers")
		end)

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
	repeat task.wait()
 	until DataCache[player] ~= nil or player:IsDescendantOf(Players) == false
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

function DataService:Set(Player, Key, Value)
	local PlayerData = GetData(Player)
	repeat task.wait() until PlayerData
	local Typeof = type(Value)

	if Typeof == "table" then
		PlayerData.Data[Key] = Value
		return true
	else
		PlayerData.Data[Key] = tostring(Value)
	end

	PlayerData.Data[Key] = tonumber(Value)

	local leaderstats = Player:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats[Key].Value = tonumber(Value)
	end

	return true
end

function DataService.Client:GetUnlockedZones(Player)
	local PlayerData = GetData(Player)
	repeat task.wait()
		PlayerData = GetData(Player)
	 until PlayerData

	assert(PlayerData.Data["UnlockedZones"], string.format("Key %s does not exist", "UnlockedZones"))
	local Data = PlayerData.Data["UnlockedZones"] or error(string.format("Key %s does not exist", "UnlockedZones"))

	return Data
end

function DataService:SetTable(Player, Table, Key, Value)
	if not Player then return end
	if not DataCache[Player] then return end
	Table[Key] = Value
end

function DataService:SetInventory(Player)
	local PlayerData = GetData(Player)
	repeat
		PlayerData = GetData(Player)
		task.wait() until PlayerData
	local playerInventory = Player:FindFirstChild("Inventory"):GetChildren()
	PlayerData.Data["Inventory"] = {}
	for _, Item in playerInventory do
		table.insert(PlayerData.Data["Inventory"], Item.Name)
	end
	return DataService:Set(Player, "Inventory", PlayerData.Data["Inventory"])
end

function DataService:Save(Player)
	local PlayerData = GetData(Player)
	repeat task.wait() until PlayerData
	local BlockInventory = Player:FindFirstChild("BlockInventory"):GetChildren()
	PlayerData.Data["BlockInventory"] = {}
	for _, Item in BlockInventory do
		PlayerData.Data["BlockInventory"][Item.Name] = Item.Value
	end
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

function DataService.Client:GetGliderData(Player)
	local PlayerData = GetData(Player)
	repeat task.wait() until PlayerData
	local GliderData = PlayerData.Data["Gliders"]
	return GliderData
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
