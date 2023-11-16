local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService") 

local Queue = require(ReplicatedStorage.Packages.Queue)

local HTTPQueue = Queue.new()
HTTPQueue.Step = 1/8

local RobloxAPIHandler = { -- economy.roblox.com/v2/assets/${asset}/details
	CursorDepthLimit = 10,
	Proxy = "https://%sroproxy.com",
	GetAssetInfo = {"economy","/v2/assets/%s/details"},
	GetGameList = {"games","/v2/users/%s/games?accessFilter=Public&limit=50"},
	GetGamepassList = {"games","/v1/games/%s/game-passes?sortOrder=Asc&limit=10"},
	InventoryGamepassItemsURL = {"games","/v2/users/%s/games?sortOrder=Asc&accessFilter=Public&limit=50&cursor=%s"},
	SearchMarketplaceURL = {"catalog","/v1/search/items/details?SortOrder=Asc&Category=3&CreatorName=%s&Cursor=%s"}
} 

function RobloxAPIHandler.Warn(...)
	warn("[RobloxAPIHandler]:",...)
end

function RobloxAPIHandler.CreateProxyURL(Builder) 
	local Prefix = Builder[1] and Builder[1] .. "." or "" 
	
	local URL =RobloxAPIHandler.Proxy:format(Prefix) 
	return URL .. Builder[2]
end

function RobloxAPIHandler.GetUpToDateProductInfo(AssetID)

	local RequestURL = RobloxAPIHandler.CreateProxyURL(RobloxAPIHandler.GetAssetInfo):format(AssetID) 
	local Success, Result = pcall(function() 
		return HttpService:GetAsync(RequestURL)
	end) 
	
	if not Success then 
		RobloxAPIHandler.Warn("Failure->",Result)
		return nil 
	end

	local JSONData : string = Result
	local Success , Result = pcall(function()
		return HttpService:JSONDecode(JSONData)
	end)

	if not Success then
		RobloxAPIHandler.Warn("Failure->",Result)
		return false 
	end
	
	return Result
end

function RobloxAPIHandler.GetUserGamepassesFromGames(PlayerID)

	local RequestURL = RobloxAPIHandler.CreateProxyURL(RobloxAPIHandler.GetGameList):format(PlayerID)
	local Success, Result = pcall(function()
		return HttpService:GetAsync(RequestURL)
	end)
	if not Success then
		warn(RequestURL)
		RobloxAPIHandler.Warn("Failure->",Result)
		return false 
	end 

	local JSONData : string = Result
	local Success , Result = pcall(function()
		return HttpService:JSONDecode(JSONData)
	end)

	if not Success then
		RobloxAPIHandler.Warn("Failure->",Result)
		return false 
	end
	
	local PlaceIDs =  {} 
	
	if Result.data then 
		for _,PlaceData in Result.data do 
			table.insert(PlaceIDs,PlaceData.id)
		end
	end
	
	local GamepassData = {} 
	
	for _,PlaceID in ipairs(PlaceIDs) do 
		local RequestURL = RobloxAPIHandler.CreateProxyURL(RobloxAPIHandler.GetGamepassList):format(PlaceID)
		local Success, Result = pcall(function()
			return HttpService:GetAsync(RequestURL)
		end)
		if Success then
			local JSONData : string = Result
			local Success , Result = pcall(function()
				return HttpService:JSONDecode(JSONData)
			end)

			if Success then
				if Result.data and #Result.data > 0 then 
					for _,RawGamepassData in Result.data do 
						table.insert(GamepassData,RawGamepassData)	
					end
				end
			end 
		else 
			warn("======ERROR====")
			warn(RequestURL)
			warn(Result)
		end
	end

	return true, GamepassData
end

local function InventoryGamepassItemsRecursiveAsync(PlayerID, Items, Cursor, Depth)
	Depth = (Depth and Depth+1) or 0 
	Items = Items or {}  
	Cursor = Cursor or "" 
	local RequestURL = RobloxAPIHandler.CreateProxyURL(RobloxAPIHandler.InventoryGamepassItemsURL):format(PlayerID,Cursor)
	local Success, Result = pcall(function()
		return HttpService:GetAsync(RequestURL)
	end)
	
	if not Success then
		RobloxAPIHandler.Warn("Failure->",Result)
		return false 
	end 

	local JSONData : string = Result
	local Success , Result = pcall(function()
		return HttpService:JSONDecode(JSONData)
	end)

	if not Success then
		RobloxAPIHandler.Warn("Failure->",Result)
		return false 
	end 

	warn(Result)
	
end

local function SearchCatalogItemsRecursiveAsync(Username, Items, Cursor, Depth)
	Depth = (Depth and Depth+1 ) or 0 
	Items = Items or {}
	Cursor = Cursor or ""
	
	local RequestURL = RobloxAPIHandler.CreateProxyURL(RobloxAPIHandler.SearchMarketplaceURL):format(Username, Cursor)
	local Success, Result = pcall(function()
		return HttpService:GetAsync(RequestURL)
	end)

	if not Success then
		if #Items > 0 then 
			return true, Items
		end
		
		RobloxAPIHandler.Warn("Failure->",Result)
		return false 
	end 

	local JSONData : string = Result
	local Success , Result = pcall(function()
		return HttpService:JSONDecode(JSONData)
	end)
	
	if not Success then
		if #Items > 0 then 
			return true, Items
		end
		
		RobloxAPIHandler.Warn("Failure->",Result)
		return false 
	end 

	local Result : {number} = Result
	for _, Item in ipairs(Result.data) do
		table.insert(Items, Item)
	end
	
	warn(Depth,Username,Items,Result.nextPageCursor)
	
	Cursor = Result.nextPageCursor
	if Cursor then
		if Depth > RobloxAPIHandler.CursorDepthLimit then 
			return true, Items
		end
		return SearchCatalogItemsRecursiveAsync(Username, Items, Cursor, Depth)
	end
	return true , Items
end

RobloxAPIHandler.SearchCatalogItemsRecursiveAsync = SearchCatalogItemsRecursiveAsync

return RobloxAPIHandler