local Gliders = require(script.Parent.Gliders)
local Trails = require(script.Parent.Trails)

local Items = {}

Items["Coins"] = {}
Items["Gliders"] = {}
Items["Spins"] = {}
Items["Gamepass"] = {}
Items["Trails"] = {}

Items["Coins"][1] = 1687766968 -- 100 Coins
Items["Coins"][2] = 1687767053 -- 500 Coins
Items["Coins"][3] = 1687767186 -- 2000 Coins
Items["Coins"][4] = 1687767340 -- 5000 Coins
Items["Coins"][5] = 1687767419 -- 10000 Coins
Items["Coins"][6] = 1699686212 -- 100000 Coins

Items["Spins"][1] = 1687767812 -- 1 Spin
Items["Spins"][2] = 1687767849 -- 5 Spins
Items["Spins"][3] = 1687767990 -- 10 Spins

Items["Gamepass"][1] = 656809264 -- VIP
Items["Gamepass"][2] = 647946037 -- 2x Wins 
Items["Gamepass"][3] = 655593490 -- 2x Coins
Items["Gamepass"][4] = 652764638 -- Batwing Glider
Items["Gamepass"][5] = 667487004 -- Meme Bundle
Items["Gamepass"][6] = 666963418 -- Fantasy Bundle
--Items["Gamepass"][7] = 667826914 -- Robot Bundle

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
		Price = 2500;
		Image = "rbxassetid://0";
		Description = "A blue and white glider";
		Owned = false;
		Glider = Gliders["Blue and White Glider"];
		ListLayout = 2;
	};

	["Red and White Glider"] = {
		Name = "Red and White Glider";
		Price = 2500;
		Image = "rbxassetid://0";
		Description = "A red and white glider";
		Owned = false;
		Glider = Gliders["Red and White Glider"];
		ListLayout = 3;
	};

	["Green and White Glider"] = {
		Name = "Green and White Glider";
		Price = 2500;
		Image = "rbxassetid://0";
		Description = "A green and white glider";
		Owned = false;
		Glider = Gliders["Green and White Glider"];
		ListLayout = 4;
	};

	["Yellow and White Glider"] = {
		Name = "Yellow and White Glider";
		Price = 2500;
		Image = "rbxassetid://0";
		Description = "A yellow and white glider";
		Owned = false;
		Glider = Gliders["Yellow and White Glider"];
		ListLayout = 5;
	};

	["Parrot Glider"] = {
		Name = "Parrot Glider";
		Price = 7250;
		Image = "rbxassetid://0";
		Description = "A parrot glider";
		Owned = false;
		Glider = Gliders["Parrot Glider"];
		ListLayout = 6;
	};

	["Paper Plane Glider"] = {
		Name = "Paper Plane Glider";
		Price = 25000;
		Image = "rbxassetid://0";
		Description = "A paper plane glider";
		Owned = false;
		Glider = Gliders["Paper Plane Glider"];
		ListLayout = 7;
	};

	["Dragon Fly Glider"] = {
		Name = "Dragon Fly Glider";
		Price = 32500;
		Image = "rbxassetid://0";
		Description = "A dragon fly glider";
		Owned = false;
		Glider = Gliders["Dragon Fly Glider"];
		ListLayout = 8;
	};

	["Plane Engine Glider"] = {
		Name = "Plane Engine Glider";
		Price = 42500;
		Image = "rbxassetid://0";
		Description = "A plane engine glider";
		Owned = false;
		Glider = Gliders["Plane Engine Glider"];
		ListLayout = 9;
	};

	["Helicopter Glider"] = {
		Name = "Helicopter Glider";
		Price = 50000;
		Image = "rbxassetid://0";
		Description = "A helicopter glider";
		Owned = false;
		Glider = Gliders["Helicopter Glider"];
		ListLayout = 10;
	};

	["Jet Glider"] = {
		Name = "Jet Glider";
		Price = 130000;
		Image = "rbxassetid://0";
		Description = "A jet glider";
		Owned = false;
		Glider = Gliders["Jet Glider"];
		ListLayout = 11;
	};

	["Rocket Glider"] = {
		Name = "Rocket Glider";
		Price = 250000;
		Image = "rbxassetid://0";
		Description = "A rocket glider";
		Owned = false;
		Glider = Gliders["Rocket Glider"];
		ListLayout = 12;
	};

	["Golden Glider"] = {
		Name = "Golden Glider";
		Price = 1000000;
		Image = "rbxassetid://0";
		Description = "A golden glider";
		Owned = false;
		Glider = Gliders["Golden Glider"];
		ListLayout = 13;
	};

    ["Batwings Glider"] = {
        Name = "Batwings Glider";
        Price = "129 Robux";
        Gamepass = 652764638;
        Image = "rbxassetid://0";
        Description = "A Batwings glider";
        Owned = false;
        Glider = Gliders["Batwings Glider"];
        ListLayout = 14;
    };

    ["Fantasy Glider"] = {
        Name = "Fantasy Glider";
        Price = "529 Robux";
        Gamepass = 666963418;
        Image = "rbxassetid://0";
        Description = "A Fantasy glider";
        Owned = false;
        Glider = Gliders["Fantasy Glider"];
        ListLayout = 15;
    };

    ["Meme Glider"] = {
        Name = "Meme Glider";
        Price = "529 Robux";
        Gamepass = 667487004;
        Image = "rbxassetid://0";
        Description = "A Meme glider";
        Owned = false;
        Glider = Gliders["Meme Glider"];
        ListLayout = 16;
    };

    --[[["Robot Glider"] = {
        Name = "Robot Glider";
        Price = "529 Robux";
        Gamepass = 667826914;
        Image = "rbxassetid://0";
        Description = "A Robot glider";
        Owned = false;
        Glider = Gliders["Robot Glider"];
        ListLayout = 17;
    };]]
}

Items["Trails"][1] = {
    ["Cloud Trail"] = {
        Name = "Cloud Trail";
        Price = 22500;
        Image = "rbxassetid://0";
        Description = "A cloud trail";
        Owned = false;
        Trail = Trails["Cloud Trail"];
        ListLayout = 1;
    };

    ["Fire Trail"] = {
        Name = "Fire Trail";
        Price = 42500;
        Image = "rbxassetid://0";
        Description = "A fire trail";
        Owned = false;
        Trail = Trails["Fire Trail"];
        ListLayout = 2;
    };

    ["Poison Trail"] = {
        Name = "Poison Trail";
        Price = 42500;
        Image = "rbxassetid://0";
        Description = "A poison trail";
        Owned = false;
        Trail = Trails["Poison Trail"];
        ListLayout = 3;
    };

    ["Star Trail"] = {
        Name = "Star Trail";
        Price = 100000;
        Image = "rbxassetid://0";
        Description = "A star trail";
        Owned = false;
        Trail = Trails["Star Trail"];
        ListLayout = 4;
    };

    ["Rainbow Trail"] = {
        Name = "Rainbow Trail";
        Price = 175000;
        Image = "rbxassetid://0";
        Description = "A rainbow trail";
        Owned = false;
        Trail = Trails["Rainbow Trail"];
        ListLayout = 5;
    };

    ["Meme Trail"] = {
        Name = "Meme Trail";
        Price = "529 Robux";
        Gamepass = 667487004;
        Image = "rbxassetid://0";
        Description = "A meme trail";
        Owned = false;
        Trail = Trails["Meme Trail"];
        ListLayout = 6;
    };

    ["Fantasy Trail"] = {
        Name = "Fantasy Trail";
        Price = "529 Robux";
        Gamepass = 666963418;
        Image = "rbxassetid://0";
        Description = "A Fantasy trail";
        Owned = false;
        Trail = Trails["Fantasy Trail"];
        ListLayout = 7;
    };

    --[[["Robot Trail"] = {
        Name = "Robot Trail";
        Price = "529 Robux";
        Gamepass = 667826914;
        Image = "rbxassetid://0";
        Description = "A Robot trail";
        Owned = false;
        Trail = Trails["Robot Trail"];
        ListLayout = 8;
    };]]
}

return Items