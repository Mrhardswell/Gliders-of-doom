local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local MovingPart = Knit.Component.new {
    Tag = "MovingPart",
}

function MovingPart:Construct()
    self.Model = self.Instance
end

function MovingPart.Start(self)
    repeat task.wait() until Knit.FullyStarted

    self.Model:GetAttributeChangedSignal("Active"):Connect(function()
        if self.Model:GetAttribute("Active") then

            if self.Connection then
                self.Connection:Disconnect()
            end

            self.Connection = RunService.RenderStepped:Connect(function(deltaTime)
                local sineValue = math.sin(deltaTime * 3.5) * 2
                self.Model.Position = Vector3.new(self.Model.Position.X + sineValue, self.Model.Position.Y, self.Model.Position.Z)
            end)
        else
            self.Connection:Disconnect()
        end
    end)

    self.Model:SetAttribute("Active", true)
end

return MovingPart
