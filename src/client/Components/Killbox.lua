local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Killbox = Knit.Component.new {
    Tag = "Killbox",
}

function Killbox:Construct()
    self.Model = self.Instance
end

function Killbox.Start(self)
    repeat task.wait() until Knit.FullyStarted

    self.Model.Touched:Connect(function(Hit)
        local Humanoid = Hit.Parent:FindFirstChild("Humanoid")
        if not Humanoid then return end
        Humanoid.Health = 0
    end)

end

return Killbox