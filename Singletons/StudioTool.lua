local Selection = game:GetService("Selection")

local CurrentSelections = Selection:Get()

for _, Instance in CurrentSelections do
    for _, Item in ipairs(Instance:GetDescendants()) do
        if Item:IsA("Texture") then
            Item:Destroy()
        end
        if Item:IsA("BasePart") or Item:IsA("MeshPart") or Item:IsA("UnionOperation") then
            Item.Material = Enum.Material.Plastic
            Item.MaterialVariant = "Checker"
        end
    end
end