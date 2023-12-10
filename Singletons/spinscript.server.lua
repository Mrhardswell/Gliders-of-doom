local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage.RemoteEvents
local SpinWheel = Remotes.SpinWheel

local DataTypeHandler = require(ReplicatedStorage.Shared.Modules.DataTypeHandler)

local Knit = require(ReplicatedStorage.Packages.Knit)

repeat task.wait() until Knit.FullyStarted

local UGCService = Knit.GetService("UGCService")

local Rewards = {
	["1"] = 1,
	["2"] = 93,
	["3"] = 1,
	["4"] = 2,
	["5"] = 3,
}

local ActiveCountdowns = {}

local function getRandomReward()
	local TotalRewardsWeight = 0

	for _, RewardWeight in Rewards do
		TotalRewardsWeight = TotalRewardsWeight + RewardWeight
	end

	local randomGenerator = Random.new()
	local randomNumber =  randomGenerator:NextInteger(1, TotalRewardsWeight)

	for Reward, Weight in Rewards do
		if randomNumber <= Weight then
			return Reward
		else
			randomNumber -= Weight
		end
	end
end

local GameSettings = ServerStorage.GameSettings
local GameSettings = ServerStorage.GameSettings
local UGCID = GameSettings.UGCID.Value
local UGCID2 = GameSettings.UGCID2.Value
local UGCID3 = GameSettings.UGCID3.Value
local UGCID4 = GameSettings.UGCID4.Value

SpinWheel.OnServerEvent:Connect(function(player)
    local leaderstats = player:WaitForChild("leaderstats")
	local Coins = leaderstats:WaitForChild("Coins")
	local CurrentCoins = DataTypeHandler:StringToNumber(Coins.Value)

	if player:WaitForChild("Data"):WaitForChild("WheelSpins").Value >= 1 then
		if player then
			local reward = getRandomReward()

			if reward then
				player.Data.WheelSpins.Value -= 1

				SpinWheel:FireClient(player, reward)

				if reward == "1" then
					task.wait(4)
					UGCService:AwardUGC(player, UGCID2)
				elseif reward == "2" then
					task.wait(4)
					Coins.Value = DataTypeHandler:NumberToString(CurrentCoins + 5000)
				elseif reward == "3" then
					task.wait(4)
					UGCService:AwardUGC(player, UGCID3)
				elseif reward == "4" then
					task.wait(4)
					UGCService:AwardUGC(player, UGCID4)
				elseif reward == "5" then
					task.wait(4)
					UGCService:AwardUGC(player, UGCID)
				end
			end
		end
	end
end)

-- Wheel Spins
local function IncrementWheelSpins(Player)
	if Player and Player.Parent and ActiveCountdowns[Player.UserId] and Players:FindFirstChild(Player.Name) then
		local SpinsAmount = 1

		if Player:IsInGroup(33193007) then
			SpinsAmount += 2
		end
	
		Player.Data.WheelSpins.Value += SpinsAmount
	end	
end

local HourSeconds = 3600

local function CountdownHour(Player)
	local SpinTime = Player:WaitForChild("SpinTime")
    local JoinTime = os.time()
    local JoinDate = os.date("!*t", JoinTime)
    local SecondsLeft = HourSeconds 

    while os.time() < JoinTime + HourSeconds and ActiveCountdowns[Player.UserId] do
        SecondsLeft = JoinTime + HourSeconds - os.time()

        local hours = math.floor(SecondsLeft / 3600)
        local minutes = math.floor((SecondsLeft % 3600) / 60)
        local seconds = SecondsLeft % 60

		SpinTime.Value = string.format("%02dh %02dm %02ds", hours, minutes, seconds)
        task.wait(1)
    end

	
	IncrementWheelSpins(Player)
end

Players.PlayerAdded:Connect(function(Player)
	ActiveCountdowns[Player.UserId] = true

	while ActiveCountdowns[Player.UserId] do
		CountdownHour(Player)
	end
end)

Players.PlayerRemoving:Connect(function(Player)
	ActiveCountdowns[Player.Name] = nil
end)