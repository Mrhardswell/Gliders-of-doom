local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Aerodynamic = Knit.CreateService {
    Name = "Aerodynamic";
    Client = {};
}

local Start = function(self)
    self.GlobalWind = workspace.GlobalWind
    self.Gravity = workspace.Gravity
    self.AirDensity = workspace.AirDensity

    self.Game = Knit.GetService("GameService")
    self.GameState = self.Game.GameState

    local DesiredWind = Vector3.new(0, 5, 0)
    local DesiredAirDensity = 0.04

    workspace.GlobalWind = DesiredWind
    workspace.AirDensity = DesiredAirDensity

end

function Aerodynamic:KnitStart()
    task.spawn(Start, self)
end

return Aerodynamic