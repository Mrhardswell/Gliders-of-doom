local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.Components = {}
Knit.Component = require(ReplicatedStorage.Packages.Component)

Knit.Player = game.Players.LocalPlayer

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

for _, component in script.Components:GetChildren() do
    Knit.Components[component.Name] = require(component)
end

Knit.AddControllers(script.Controllers)
Knit.Start():catch(warn)