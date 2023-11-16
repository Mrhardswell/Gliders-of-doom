local TweenService = game:GetService("TweenService")
local TweenInfos = require(script:WaitForChild("TweenInfos"))

local function CreateTween(Object, Properties, Info)
    return TweenService:Create(Object, TweenInfos[Info] or TweenInfos.Default, Properties)
end

local Tweens = {}
Tweens.__index = Tweens
Tweens.Cache = {}

type Tween = {
    Play: () -> nil;
    Pause: () -> nil;
    Destroy: () -> nil;
    Cancel: () -> nil;
}

export type Tweens = {
    Create: (Object: Instance, Properties: {}, TweenName: string, Info: string ) -> Tween;
    Play: () -> Tween;
    Pause: () -> nil;
    Destroy: () -> nil;
    Cancel: () -> nil;
}

function Tweens:AddTweenInfo(Name: string, TweenInfo: TweenInfo)
    assert(Name, "Name is nil!")
    assert(TweenInfo, "TweenInfo is nil!")
    TweenInfos[Name] = TweenInfo
end

function Tweens:Create(Object, Properties, TweenName, Info)
    assert(Object, "Object is nil!")
    assert(Properties, "Properties is nil!")
    assert(TweenName, "TweenName is nil!")

    if not Tweens.Cache[Object] then
        Tweens.Cache[Object] = {}
        Tweens.Cache[Object][TweenName] = CreateTween(Object, Properties, Info)
    elseif not Tweens.Cache[Object][TweenName] then
        Tweens.Cache[Object][TweenName] = CreateTween(Object, Properties, Info)
    end

    return Tweens.Cache[Object][TweenName]
end

function Tweens:Play(Object, TweenName)

    assert(Object, "Object is nil!")
    assert(TweenName, "TweenName is nil!")

    if not Tweens.Cache[Object] then
        warn("Tween does not exist!")
    elseif not Tweens.Cache[Object][TweenName] then
        warn("Tween does not exist!")
    else
        Tweens.Cache[Object][TweenName]:Play()
    end
    return Tweens.Cache[Object][TweenName]
end

function Tweens:Pause(Object, TweenName)
    assert(Object, "Object is nil!")
    assert(TweenName, "TweenName is nil!")

    if not Tweens.Cache[Object] then
        warn("Tween does not exist!")
    elseif not Tweens.Cache[Object][TweenName] then
        warn("Tween does not exist!")
    else
        Tweens.Cache[Object][TweenName]:Pause()
    end
end

function Tweens:Destroy(Object, TweenName)
    assert(Object, "Object is nil!")
    assert(TweenName, "TweenName is nil!")

    if not Tweens.Cache[Object] then
        warn("Tween does not exist!")
    elseif not Tweens.Cache[Object][TweenName] then
        warn("Tween does not exist!")
    else
        Tweens.Cache[Object][TweenName]:Destroy()
        Tweens.Cache[Object][TweenName] = nil
    end
end

function Tweens:Cancel(Object, TweenName)
    assert(Object, "Object is nil!")
    assert(TweenName, "TweenName is nil!")

    if not Tweens.Cache[Object] then
        warn("Tween does not exist!")
    elseif not Tweens.Cache[Object][TweenName] then
        warn("Tween does not exist!")
    else
        Tweens.Cache[Object][TweenName]:Cancel()
    end
end

return Tweens

-- By MrHardswell, 2023

-- Note: This is a module that allows you to create tweens easily, and cache them for later use.