local RepStorage = game:GetService("ReplicatedStorage")

local MPS = game:GetService("MarketplaceService")
local Remotes = RepStorage.RemoteEvents
local Remote = Remotes.SpinWheel
local ServerScriptService = game:GetService("ServerScriptService")
local DataStore2 = require(RepStorage.ModuleScripts.DataStore2)
local ugcHandler = require(ServerScriptService.UGCHandler)

local DataTypeHandler = require(game.ReplicatedStorage.Shared.Modules.DataTypeHandler)

local Knit = require(RepStorage.Packages.Knit)

repeat task.wait() until Knit.FullyStarted

local UGCService = Knit.GetService("UGCService")

DataStore2.Combine("DATA", "MinutesLeft")

local Rewards = {
	["1"] = 1,
	["2"] = 90,
	["3"] = 2,
	["4"] = 1,
	["5"] = 1,
}

local function getRandomReward()
	local totalWeight = 0
	for _, weight in Rewards do
		totalWeight = totalWeight + weight
	end

	local randomNumber = math.random() * totalWeight
	local accumulatedWeight = 0

	for reward, weight in Rewards do
		accumulatedWeight = accumulatedWeight + weight
		if accumulatedWeight >= randomNumber then
			return reward
		end
	end
end

local ServerStorage = game:GetService("ServerStorage")
local GameSettings = ServerStorage.GameSettings
local UGCID = GameSettings.UGCID.Value

Remote.OnServerEvent:Connect(function(player)
    local leaderstats = player:WaitForChild("leaderstats")
    local Coins = leaderstats:WaitForChild("Coins")
    local CurrentCoins = DataTypeHandler:StringToNumber(Coins.Value)

	if player:WaitForChild("Data"):WaitForChild("WheelSpins").Value >= 1 then
		if player then
			local reward = getRandomReward()

			if reward then
				player:WaitForChild("Data"):WaitForChild("WheelSpins").Value -= 1
				Remote:FireClient(player, reward)
				if reward == "1" then
					task.wait(4)
					Coins.Value = DataTypeHandler:NumberToString(CurrentCoins + 500)
				elseif reward == "2" then
					task.wait(4)
					Coins.Value = DataTypeHandler:NumberToString(CurrentCoins + 2500)
				elseif reward == "3" then
					task.wait(4)
					Coins.Value = DataTypeHandler:NumberToString(CurrentCoins + 7500)
				elseif reward == "4" then
					task.wait(4)
					Coins.Value = DataTypeHandler:NumberToString(CurrentCoins + 10000)
				elseif reward == "5" then
					task.wait(4)
					UGCService:AwardUGC(player, UGCID)
				end
			end
		end
	end

end)

-- Wheel Spins
local function IncrementWheelSpins(player)
	if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.UserId, 645182658) then
		player:WaitForChild("Data"):WaitForChild("WheelSpins").Value = player:WaitForChild("Data"):WaitForChild("WheelSpins").Value + 2
	else
		player:WaitForChild("Data"):WaitForChild("WheelSpins").Value = player:WaitForChild("Data"):WaitForChild("WheelSpins").Value + 1
	end
end

local function giveSpins(player, amount)
		player:WaitForChild("Data"):WaitForChild("WheelSpins").Value = player:WaitForChild("Data"):WaitForChild("WheelSpins").Value + amount
end

script.GiveSkips.Event:Connect(function(player, amount)
	giveSpins(player, amount)
end)

game.Players.PlayerAdded:Connect(function(player)
	task.wait(2)
	coroutine.resume(coroutine.create(function()
		if player:IsInGroup(33193007) then
			local minutesLeftStore = DataStore2("MinutesLeft", player)
			local startingMinute = minutesLeftStore:Get(0)
			if startingMinute >= 60 then
				minutesLeftStore:Increment(-60)
				IncrementWheelSpins(player)
			end
			while true do
				for minute = startingMinute, 60, 1 do
					task.wait(60)
					minutesLeftStore:Increment(1)
				end
				IncrementWheelSpins(player)
				minutesLeftStore:Increment(-60)
			end
		else
			while true do
				local minutesLeftStore = DataStore2("MinutesLeft", player)
				local startingMinute = minutesLeftStore:Get(0)
				for minute = startingMinute, 120, 1 do
					task.wait(60)
					minutesLeftStore:Increment(1)
					minutesLeftStore:Increment(-120)
				end
				IncrementWheelSpins(player)
			end
		end
	end))
end)

