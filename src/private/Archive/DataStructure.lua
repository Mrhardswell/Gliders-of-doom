local DataStructure = {}

DataStructure = {

    leaderstats = {
        Coins = "0",
        Wins = "0",
    },

    TotalPlaytime = 0,

    ClaimedRewards = {},
    VipRewardsLastClaimed = {},
    GroupRewardsLastClaimed = {},

    Gliders = { ["Basic Glider"] = true },
    LastGlider = "Basic Glider",

    Trails = {},
    LastTrail = "None",

    Settings = {
        Music = true,
        SFX = true,
    },

    Spins = 1,

    History = {},

    FastestTime = 480,

}

return DataStructure