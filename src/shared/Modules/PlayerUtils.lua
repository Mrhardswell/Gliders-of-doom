
-- this helps the client and server get the player from the character and vice versa

local Players = game:GetService("Players")

local PlayerUtils = {}

type YieldTimeType = number

function PlayerUtils.getPlayerfromCharacter(char : Model) : Player?
    local Success,Result = pcall(function()
        return Players:GetPlayerFromCharacter(char)
    end)

    if Success and Result then
        return Result
    end
    return nil
end
-- this waits for the player to be added to the game

function PlayerUtils.HidePart(part : any,Hide)
    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
        part.Transparency = Hide and 1 or 0
    elseif part:IsA("Decal") then    
        part.Transparency = Hide and 1 or 0    
    elseif part:IsA("BillboardGui") then
        part.Enabled = not Hide    
    end    
end

function PlayerUtils.ToggleHideCharacterIfAlive(player,Hide : boolean)
    task.spawn(function()
        local character : Model = player.Character
        if not character then return end
        local CharacterParts = character:GetDescendants()
        for _,part: BasePart in CharacterParts do
            PlayerUtils.HidePart(part,Hide)
        end
    end)
end

function PlayerUtils.ToggleHideCharacter(player, Hide : boolean)
    local character = PlayerUtils.getCharacter(player)
    for _,part: BasePart in (character:GetDescendants()) do
        PlayerUtils.HidePart(part,Hide)
    end
end


function PlayerUtils.getCharacter(player : Player) : Model?
    local character = player.Character or player.CharacterAdded:Wait()
    return character
end

function PlayerUtils.isPlayerInTheServer(playerName) : boolean
    if playerName then
        return Players:FindFirstChild(playerName) ~= nil
    end
    return false
end

function PlayerUtils.PlayerLeftSignal(playerDefine : Player,Callback : (player : Player) -> nil) : RBXScriptSignal | nil
    if not playerDefine then
        return nil
    end

    local Connection
    Connection = Players.PlayerRemoving:Connect(function(player)
        -- handle the player leaving disconnections
        if player == playerDefine then
            if Connection then
                Connection:Disconnect()
                Connection = nil
            end
            Callback(player)
        end

        Callback(player)
    end)

    -- incase you want to disconnect the connection
    return Connection
end

function PlayerUtils.OnPlayerDied(player,Callback : () -> nil,humanoid : Humanoid) : RBXScriptSignal | any
    -- you could use connect but i just use :Once in this case
    if humanoid and humanoid:IsA("Humanoid") then
        return humanoid.Died:Once(function()
            Callback()
        end)
    end

    local Humanoid = PlayerUtils.getHumanoid(player,15)

    return Humanoid.Died:Once(function()
        Callback()
    end)
end 

function PlayerUtils.getHumanoid(player,TimeToYield : YieldTimeType) : Humanoid?
    TimeToYield = TimeToYield or 25
    local character = PlayerUtils.getCharacter(player)
    return character:WaitForChild("Humanoid",TimeToYield) 
end

function PlayerUtils.getHumanoidRootPart(player,TimeToYield : YieldTimeType) : BasePart?
    TimeToYield = TimeToYield or 25
    local character = PlayerUtils.getCharacter(player)
    return character:WaitForChild("HumanoidRootPart",TimeToYield)
end

function PlayerUtils.getHumanoidAndHumanoidRootPart_Table(player,TimeToYield : YieldTimeType) : {Humanoid:Humanoid?,HumanoidRootPart:BasePart?}
    TimeToYield = TimeToYield or 25
   return {
    Humanoid = PlayerUtils.getHumanoid(player,TimeToYield);
    HumanoidRootPart = PlayerUtils.getHumanoidRootPart(player,TimeToYield);
    }
end

function PlayerUtils.getHumanoidAndHumanoidRootPart_Variable(player,TimeToYield : YieldTimeType)
    TimeToYield = TimeToYield or 25
    local Humanoid = PlayerUtils.getHumanoid(player,TimeToYield)
    local HumanoidRootPart = PlayerUtils.getHumanoidRootPart(player,TimeToYield)
    return Humanoid :: Humanoid?,HumanoidRootPart :: BasePart?
end



return PlayerUtils