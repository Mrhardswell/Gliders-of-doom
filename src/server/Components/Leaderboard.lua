local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Net = require(game.ReplicatedStorage.Packages.Net)

local Leaderboard = Knit.Component.new {
    Tag = "Leaderboard";
}

function Leaderboard:Construct()
    self.Leaderboard = self.Instance
    self.EntryHolder = self.Leaderboard.LeaderboardGui.EntryHolder
    self.EntryTemplate = self.EntryHolder.Entry
    self.OrderedDataStore = DataStoreService:GetOrderedDataStore(self.Leaderboard.Name)
end

function Leaderboard.Start(self)
    while true do
        self:Update()
        task.wait(30)
    end
end

function Leaderboard:Update()
    local isAscending = true
	local pageSize = 10
	local pages = self.OrderedDataStore:GetSortedAsync(isAscending, pageSize)
	local currentPage = pages:GetCurrentPage()

	for rank, data in currentPage do
		local name = data.key
		local data = data.value
        local isDisplayed = false

        for _, entry in self.EntryHolder:GetChildren()  do
            if entry.ClassName ~= "Frame" then continue end

            if entry.Name == name then
                isDisplayed = true
            end
        end

        if data and not isDisplayed then
            local entryTemplate = self.EntryTemplate:Clone()
            local userId = Players:GetUserIdFromNameAsync(name)

            if userId then
                local thumbnailIcon = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                entryTemplate.Icon.Image = thumbnailIcon
            end

            local dataToSetTo

            if self.Leaderboard.Name == "FastestTime" then
                local minutes = math.floor((data % 3600) / 60)
                local seconds = data % 60

                dataToSetTo = string.format("%02dm:%02ds", minutes, seconds)
            end

            entryTemplate.Data.Text = dataToSetTo
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