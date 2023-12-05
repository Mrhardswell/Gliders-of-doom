local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Net = require(ReplicatedStorage.Packages.Net)
local Knit = require(ReplicatedStorage.Packages.Knit)

local setLookAngles = Net:RemoteEvent("SetLookAngles")

local function onReceiveLookAngles(player, pitch, yaw)
	if typeof(pitch) ~= "number" or pitch ~= pitch then
		return
	end
	if typeof(yaw) ~= "number" or yaw ~= yaw then
		return
	end
	pitch = math.clamp(pitch, -1, 1)
	yaw = math.clamp(yaw, -1, 1)
	setLookAngles:FireAllClients(player, pitch, yaw)
end

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid and humanoid:IsA("Humanoid") then
		CollectionService:AddTag(humanoid, "RealismHook")
	end
end

local function onPlayerAdded(player)
	if player.Character then
		onCharacterAdded(player.Character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
end

local Realism_Service = Knit.CreateService {
    Name = "Realism_Service";
}

function Realism_Service:KnitInit()
    for _, player in Players:GetPlayers() do
	    onPlayerAdded(player)
    end
end

function Realism_Service:KnitStart()
    Players.PlayerAdded:Connect(onPlayerAdded)
	Net:Connect("SetLookAngles", onReceiveLookAngles)
end

return Realism_Service

-- By MrHardswell, 2023