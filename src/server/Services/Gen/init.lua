local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
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

local isCurrentMap = workspace:FindFirstChild("CurrentMap") ~= nil

local CurrentMap = isCurrentMap and workspace.CurrentMap or Instance.new("Folder")
CurrentMap.Name = "CurrentMap"

local Lobby = CollectionService:GetTagged("Lobby")[1]

local Cache = {}
local Last = nil

local function Clear()
    for _, Child in CurrentMap:GetChildren() do
        Child:Destroy()
    end
    table.clear(Cache)
    Last = nil
    print("Cleared map folder and cache!")
end

local function GetRandomChunk()
    local ChunksMeta = Chunks.ChunksMeta

    if #ChunksMeta == 0 then
        print("No chunks found!")
        return
    end

    local RandomIndex = math.random(1, #ChunksMeta)
    local RandomChunk = ChunksMeta[RandomIndex]

    if Cache[RandomChunk.Name] then
        task.wait()
        return GetRandomChunk()
    end

    Cache[RandomChunk.Name] = RandomChunk

    local TargetPos = Last and Last.Nodes.B.Position or Lobby.PrimaryPart.Position
    local Generated = RandomChunk:Generate(TargetPos)

    Last = Generated

    return RandomChunk
end

function GenService:GenerateMap()
    Clear()

    local Current = 0

    -- Chunks
    for Index = 1, ChunkAmount.Value do
        GetRandomChunk()
        Current = Index
    end

    repeat task.wait() until Current == ChunkAmount.Value

    -- Finish Line
    local Chunk_End = ServerStorage.Assets.Chunk_End
    local End = Chunk_End:Clone()

    End.Assets.End:SetAttribute("End", true)
    End.Parent = CurrentMap

    End:PivotTo(Last.Nodes.B.CFrame)

end

return GenService