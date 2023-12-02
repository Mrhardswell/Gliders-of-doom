local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local GliderFolder = Assets.Gliders

local Gliders = {}

for _, Glider in GliderFolder:GetChildren() do
    local self = {}
    self.ID = Glider.Name
    self.Accessory = Glider
    Gliders[self.ID] = self
end

return Gliders