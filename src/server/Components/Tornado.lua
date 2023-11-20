local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Tornado = Knit.Component.new {
    Tag = "Tornado",
}

function Tornado:Construct()
    self.Model = self.Instance
end

function Tornado.Start(self)

end

return Tornado