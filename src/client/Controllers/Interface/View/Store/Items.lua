local Gliders = require(script.Parent.Gliders)

local Items = {}

Items["Coins"] = {}
Items["Gliders"] = {}
Items["Spins"] = {}
Items["Gamepass"] = {}

Items["Coins"][1] = 1687766968 -- 100 Coins
Items["Coins"][2] = 1687767053 -- 500 Coins
Items["Coins"][3] = 1687767186 -- 2000 Coins
Items["Coins"][4] = 1687767340 -- 5000 Coins
Items["Coins"][5] = 1687767419 -- 10000 Coins

Items["Spins"][1] = 1687767812 -- 1 Spin
Items["Spins"][2] = 1687767849 -- 5 Spins
Items["Spins"][3] = 1687767990 -- 10 Spins

Items["Gamepass"][1] = 656809264 -- VIP
Items["Gamepass"][2] = 652764638 -- Basic Glider
Items["Gamepass"][3] = 655593490 -- 2x Coins
Items["Gamepass"][4] = 647946037 -- 2x Wins

Items["Gliders"][1] = {

    ["Basic Glider"] = {
        Name = "Basic Glider";
        Price = 0;
        Image = "rbxassetid://0";
        Description = "A basic glider";
        Owned = true;
        Glider = Gliders["Basic Glider"];
        ListLayout = 1;
    };

    ["Blue and White Glider"] = {
        Name = "Blue and White Glider";
        Price = 500;
        Image = "rbxassetid://0";
        Description = "A blue and white glider";
        Owned = false;
        Glider = Gliders["Blue and White Glider"];
        ListLayout = 2;
    };

    ["Red and White Glider"] = {
        Name = "Red and White Glider";
        Price = 500;
        Image = "rbxassetid://0";
        Description = "A red and white glider";
        Owned = false;
        Glider = Gliders["Red and White Glider"];
        ListLayout = 3;
    };

    ["Green and White Glider"] = {
        Name = "Green and White Glider";
        Price = 500;
        Image = "rbxassetid://15505022465";
        Description = "A green and white glider";
        Owned = false;
        Glider = Gliders["Green and White Glider"];
        ListLayout = 4;
    };

    ["Yellow and White Glider"] = {
        Name = "Yellow and White Glider";
        Price = 500;
        Image = "rbxassetid://0";
        Description = "A yellow and white glider";
        Owned = false;
        Glider = Gliders["Yellow and White Glider"];
        ListLayout = 5;
    };

    ["Parrot Glider"] = {
        Name = "Parrot Glider";
        Price = 1450;
        Image = "rbxassetid://0";
        Description = "A parrot glider";
        Owned = false;
        Glider = Gliders["Parrot Glider"];
        ListLayout = 6;
    };

    ["Paper Plane Glider"] = {
        Name = "Paper Plane Glider";
        Price = 5000;
        Image = "rbxassetid://0";
        Description = "A paper plane glider";
        Owned = false;
        Glider = Gliders["Paper Plane Glider"];
        ListLayout = 7;
    };

    ["Dragon Fly Glider"] = {
        Name = "Dragon Fly Glider";
        Price = 6500;
        Image = "rbxassetid://0";
        Description = "A dragon fly glider";
        Owned = false;
        Glider = Gliders["Dragon Fly Glider"];
        ListLayout = 8;
    };

    ["Plane Engine Glider"] = {
        Name = "Plane Engine Glider";
        Price = 8500;
        Image = "rbxassetid://0";
        Description = "A plane engine glider";
        Owned = false;
        Glider = Gliders["Plane Engine Glider"];
        ListLayout = 9;
    };

    ["Helicopter Glider"] = {
        Name = "Helicopter Glider";
        Price = 10000;
        Image = "rbxassetid://0";
        Description = "A helicopter glider";
        Owned = false;
        Glider = Gliders["Helicopter Glider"];
        ListLayout = 10;
    };

    ["Jet Glider"] = {
        Name = "Jet Glider";
        Price = 26000;
        Image = "rbxassetid://0";
        Description = "A jet glider";
        Owned = false;
        Glider = Gliders["Jet Glider"];
        ListLayout = 11;
    };

    ["Rocket Glider"] = {
        Name = "Rocket Glider";
        Price = 50000;
        Image = "rbxassetid://0";
        Description = "A rocket glider";
        Owned = false;
        Glider = Gliders["Rocket Glider"];
        ListLayout = 12;
    };

}

return Items