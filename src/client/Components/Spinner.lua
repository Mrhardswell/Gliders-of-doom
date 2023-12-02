local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Spinner = Knit.Component.new {
    Tag = "Spinner",
}

function Spinner:Construct()
    self.Model = self.Instance
end

function Spinner.Start(self)
    repeat task.wait() until Knit.FullyStarted

    self.Model:GetAttributeChangedSignal("Active"):Connect(function()
        if self.Model:GetAttribute("Active") then

            if self.Connection then
                self.Connection:Disconnect()
            end

            self.Connection = RunService.RenderStepped:Connect(function(deltaTime)
                self.Model.CFrame = self.Model.CFrame * CFrame.Angles(0, 0, 0.5 * deltaTime)
            end)
        else
            self.Connection:Disconnect()
        end
    end)

    self.Model:SetAttribute("Active", true)
end

return Spinner
