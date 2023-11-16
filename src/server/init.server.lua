local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)

Knit.Component = require(ReplicatedStorage.Packages.Component)
Knit.Private = require(ServerStorage.Private)

local Message = Net:RemoteEvent("ServerMessage")

Knit.Components = {}

Knit.ServerMessage = Message

for _, Component in script.Components:GetChildren() do
    if not Component:IsA("ModuleScript") then continue end
    Knit.Components[Component.Name] = require(Component)
end

Knit.AddServices(script.Services)
Knit.Start():catch(warn)
