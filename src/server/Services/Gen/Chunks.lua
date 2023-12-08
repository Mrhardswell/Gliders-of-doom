local ServerStorage = game:GetService("ServerStorage")
local Assets = ServerStorage.Assets
local ChunksFolder = Assets.Chunks

local Chunks = {}
local ChunksMeta = {}

-- Chunk Class
function Chunks.new(Chunk : Folder)
    local self = {}
    self.Folder = Chunk
    self.Name = Chunk.Name

    self.Nodes = Chunk.Nodes
    self.PrimaryPart = Chunk.PrimaryPart

    return self
end

-- Chunk Cache
local function CacheChunks()
    table.clear(ChunksMeta)
    for Index, Chunk : Folder in ipairs(ChunksFolder:GetChildren()) do
        ChunksMeta[Index] = Chunks.new(Chunk)
    end
end

CacheChunks()

Chunks.ChunksMeta = ChunksMeta

return Chunks