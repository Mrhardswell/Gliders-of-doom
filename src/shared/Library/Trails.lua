local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local TrailsFolder = Assets.Trails

local Trails = {}

for _, Trail in TrailsFolder:GetChildren() do
    local self = {}
    self.ID = Trail.Name
    self.Accessory = Trail
    Trails[self.ID] = self
end

return Trails