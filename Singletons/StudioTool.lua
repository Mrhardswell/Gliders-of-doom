local Selection = game:GetService("Selection")
local CollectionService = game:GetService("CollectionService")

local Tag = "Killbox"

local CurrentSelections = Selection:Get()

for _, Instance in CurrentSelections do
    for _, ToTag in ipairs(Instance:GetDescendants()) do
        if ToTag:IsA("BasePart") or ToTag:IsA("MeshPart") or ToTag:IsA("UnionOperation") then
            CollectionService:AddTag(ToTag, Tag)
        end
    end
end