local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Prompter = Knit.Component.new {
    Tag = "Prompter",
}

local player = game:GetService("Players").LocalPlayer

function Prompter:Construct()
    self.Model = self.Instance
    self.ProximityPrompt = Instance.new("ProximityPrompt")
    self.Title = self.Model.TagHolder.Title
    self.Type = self.Model:GetAttribute("Type")
    self.ID = self.Model:GetAttribute("ID")

    self.Title.Frame.Title.Text = self.Model.Name
    
    self.ProximityPrompt.Parent = self.Model.PromptHolder
    self.ProximityPrompt.RequiresLineOfSight = false
    
end

function Prompter.Start(self)
    repeat task.wait() until Knit.FullyStarted

    self.ProximityPrompt.Triggered:Connect(function()
        if self.Type == "Gamepass" then
            MarketplaceService:PromptGamePassPurchase(player, self.ID)
        else
            MarketplaceService:PromptProductPurchase(player, self.ID)
        end    
    end)

end

return Prompter
