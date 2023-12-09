local Selection = game:GetService("Selection")

local Selected = Selection:Get()[1]

local function SetCollide(Instance, Collide)
    if Instance:IsA("BasePart") or Instance:IsA("MeshPart") then
        Instance.CanCollide = Collide
    end
end

for _, Child in ipairs(Selected:GetDescendants()) do
    SetCollide(Child, false)
end