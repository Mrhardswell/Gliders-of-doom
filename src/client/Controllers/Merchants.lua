local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Net = require(game.ReplicatedStorage.Packages.Net)

local Interface

local MerchantController = Knit.CreateController { Name = "MerchantController" }

function MerchantController:KnitStart()
    Interface = Knit.GetController("InterfaceController")
end

Net:Connect("PromptTriggered", function(Type, Model)
    print("PromptTriggered", Type, Model)
    if Type == "VIP" then
        Interface:OpenUI("VipRewards")
    end
    if Type == "Group" then
        Interface:OpenUI("GroupRewards")
    end
end)

return MerchantController