local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Shared = ReplicatedStorage.Shared
local Rewards = require(Shared.Rewards)
local DataTypeHandler = require(Shared.Modules.DataTypeHandler)

local Knit = require(ReplicatedStorage.Packages.Knit)

local MusicService = Knit.CreateService {
    Name = "MusicService";
    Client = {};
}

function MusicService:KnitStart()
    self.MusicFolder = SoundService.Music:GetChildren()

    MusicService:RotateMusic()
end

function MusicService:RotateMusic()
    while true do
        for i = 1, #self.MusicFolder, 1 do
            local Music = self.MusicFolder[i]

            Music:Play()
            task.wait(Music.TimeLength)
            Music:Stop()
        end 
    end
end

return MusicService