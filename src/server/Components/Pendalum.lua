local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Pendalum = Knit.Component.new {
    Tag = "Pendalum",
}

function Pendalum:ToggleAngle()
    if self.HingeConstraint.TargetAngle == self.HingeConstraint.UpperAngle then
        self.HingeConstraint.TargetAngle = self.HingeConstraint.LowerAngle
    else
        self.HingeConstraint.TargetAngle = self.HingeConstraint.UpperAngle
    end
end

function Pendalum:Construct()
    self.Model = self.Instance
    self.Pendalum = self.Model.Pendalum
    self.Pendalum:SetNetworkOwner(nil)
    self.HingeConstraint = self.Model.HingeConstraint
    self.Speed = self.Model:GetAttribute("Speed")
end

function Pendalum.Start(self)
    repeat task.wait() until Knit.FullyStarted

    self.Model:GetAttributeChangedSignal("Active"):Connect(function()
        if not self.Model:GetAttribute("Active") then return end
        while self.Model:GetAttribute("Active") do
            self:ToggleAngle()
            task.wait(self.Speed)
        end
    end)

    self.Model:SetAttribute("Active", true)
end

return Pendalum