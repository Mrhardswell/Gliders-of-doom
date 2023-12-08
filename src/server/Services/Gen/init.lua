local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Chunks = require(script.Chunks)

local GameSettings = ServerStorage.GameSettings
local GenSettings = GameSettings.Generation
local ChunkAmount = GenSettings.ChunkAmount

local GenService = Knit.CreateService {
    Name = "GenService",
    Client = {},
}

local CurrentMap = Instance.new("Folder", workspace)
CurrentMap.Name = "CurrentMap"

local function GetRandomChunk()
    local ChunksMeta = Chunks.ChunksMeta

    if #ChunksMeta == 0 then
        print("No chunks found!")
        return
    end

    local RandomIndex = math.random(1, #ChunksMeta)

    if table.find(ChunksMeta, ChunksMeta[RandomIndex]) then
        return GetRandomChunk()
    end

    local RandomChunk = ChunksMeta[RandomIndex]
    return RandomChunk
end

function GenService:KnitStart()
    print(Chunks.ChunksMeta)
    print(ChunkAmount.Value)
    print(GetRandomChunk())
end

return GenService