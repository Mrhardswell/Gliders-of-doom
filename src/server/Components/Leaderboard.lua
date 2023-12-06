local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Net = require(game.ReplicatedStorage.Packages.Net)
local LeaderboardData = require(ServerScriptService.Server.Services.Data.LeaderboardData)

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true)

local rankColors = {
    ["1"] = Color3.fromRGB(188, 157, 0),
    ["2"] = Color3.fromRGB(192, 192, 192),
    ["3"] = Color3.fromRGB(158, 96, 38),
    ["4"] = Color3.fromRGB(47, 64, 70)
}

local Leaderboard = Knit.Component.new {
    Tag = "Leaderboard";
}
function Leaderboard:Construct()
    self.Leaderboard = self.Instance
    self.LeaderboardGui = self.Leaderboard.LeaderboardGui
    self.EntryHolder = self.LeaderboardGui.EntryHolder
    self.Title = self.LeaderboardGui.Title
    self.UIGradient = self.Title.UIGradient
    self.EntryTemplate = self.EntryHolder.EntryTemplate
    self.RankTags = self.Leaderboard.Parent.RankTags
    self.RankPositions = self.Leaderboard.RankPositions
    self.OrderedDataStore = DataStoreService:GetOrderedDataStore(self.Leaderboard.Name)
    self.RankedCharacters = self.Leaderboard.RankedCharacters
    self.Tween = TweenService:Create(self.UIGradient, tweenInfo, {Offset = Vector2.new(-0.3,0)})

    self.Title.Text = LeaderboardData[self.Leaderboard.Name].Title
end

function Leaderboard.Start(self)
    self.Tween:Play()

    while true do
        self:Update()
        task.wait(60)
    end
end

function Leaderboard:Cleanup()
    for _, entry in self.EntryHolder:GetChildren() do
        if entry.ClassName ~= "Frame" then continue end
        if entry.Name == "EntryTemplate" then continue end

        entry:Destroy()
    end

    for _, character in self.RankedCharacters:GetChildren() do
        character:Destroy()
    end
end

function Leaderboard:Update()
    local ascending = LeaderboardData[self.Leaderboard.Name].Ascending
	local pageSize = 25
	local pages = self.OrderedDataStore:GetSortedAsync(ascending, pageSize)
	local currentPage = pages:GetCurrentPage()

    self:Cleanup()

	for rank, data in currentPage do
		local name = data.key
        local userId = Players:GetUserIdFromNameAsync(name)
		local data = data.value

        if rank >= 1 and rank <= 3 then
            local humanoidDescription = Players:GetHumanoidDescriptionFromUserId(userId)
            local character = Players:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15)
            local rankTag = self.RankTags[rank]
            local rankPosition = self.RankPositions[rank]
            local heightScale = humanoidDescription.HeightScale
            local typeScale = humanoidDescription.BodyTypeScale
            local proportionScale = humanoidDescription.ProportionScale
            local heightAdjustment = (heightScale*(4 + typeScale*(math.pi/2 - 0.6*proportionScale)) + 1) - 5.1
            
            character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            character.Name = name
            character.Parent = self.RankedCharacters
            character.HumanoidRootPart.Anchored = true
            character:PivotTo(rankPosition.CFrame * rankPosition.Spawn.CFrame * CFrame.new(0, heightAdjustment, 0))
            
            rankTag = rankTag:Clone()
            rankTag.Parent = character
            rankTag.Adornee = character.Head 
        end

        if data then
            local entryTemplate = self.EntryTemplate:Clone()

            if userId then
                local thumbnailIcon = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                entryTemplate.Icon.Image = thumbnailIcon
            end

            local dataToSetTo = data
            local rankColor = rankColors["4"]

            if rank < 4 then
                rankColor = rankColors[tostring(rank)]
            end

            if self.Leaderboard.Name == "FastestTime" then
                local minutes = math.floor((data % 3600) / 60)
                local seconds = data % 60

                dataToSetTo = string.format("%02dm:%02ds", minutes, seconds)
            elseif self.Leaderboard.Name == "Wins" then
                dataToSetTo = data.." Wins"
            end

            entryTemplate:SetAttribute("Data", data)
            entryTemplate.Data.Text = dataToSetTo
            entryTemplate.BackgroundColor3 = rankColor
            entryTemplate.Name = name
            entryTemplate.Player.Text = name
            entryTemplate.Rank.Text = "#"..rank
            entryTemplate.LayoutOrder = rank
            entryTemplate.Parent = self.EntryHolder
            entryTemplate.Visible = true
        end
	end
end

return Leaderboard