local ServerStorage = game:GetService("ServerStorage")
local Assets = ServerStorage.Assets
local ChunksFolder = Assets.Chunks

local Chunks = {}
local ChunksMeta = {}

local CurrentMap = Instance.new("Folder", workspace)
CurrentMap.Name = "CurrentMap"

function GenerateAndPivotTo(Chunk, TargetPos : Vector3)
    assert(Chunk, "No chunk!")
    assert(TargetPos, "No target!")

    print("Generating chunk " .. Chunk.Name .. " and pivoting to ", TargetPos)

    local Model = Chunk.Model:Clone()
    Model.Parent = CurrentMap

    local TargetCFrame = CFrame.new(TargetPos)
    Model:PivotTo(TargetCFrame)

    return Model
end

-- Chunk Class
function Chunks.new(Chunk)
    local self = {}

    self.Model = Chunk
    self.Name = Chunk.Name
    self.Nodes = Chunk.Nodes

    self.PrimaryPart = Chunk.PrimaryPart
    self.SecondaryPart = self.Nodes.B

    self.Generate = function(Meta, Target)
        if not Target then
            print("No target!")
            return self
        end
        return GenerateAndPivotTo(Meta, Target)
    end

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