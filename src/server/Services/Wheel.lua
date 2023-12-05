local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

local GameSettings = ServerStorage:WaitForChild("GameSettings")

local WheelService = Knit.CreateService {
    Name = "WheelService";
    Client = {};
}

local DataService
local UGCService

local SpinWheelSettings

function WheelService:KnitStart()
    DataService = Knit.GetService("DataService")
    UGCService = Knit.GetService("UGCService")

    SpinWheelSettings = GameSettings:WaitForChild("SpinWheel")
    self.Prizes = SpinWheelSettings:GetChildren()

end

function WheelService.Client:GetPrizes()
    local Prizes = {}

    for _, Prize in self.Server.Prizes do
        Prizes[Prize.Name] = {
            Type = Prize:GetAttribute("Type");
            Amount = Prize.Value;
        }
    end

    return Prizes
end

return WheelService