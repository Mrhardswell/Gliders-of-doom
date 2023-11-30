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

    Settings = {
        Music = true,
        SFX = true,
    }

}

return DataStructure