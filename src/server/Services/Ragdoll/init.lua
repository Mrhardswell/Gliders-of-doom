local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = game.Players.LocalPlayer

local Ragdoll = Knit.CreateService {
    Name = "RagdollService";
    Client = {};
}

local RagdollLimit = require(script.Limits)

local function resyncClothes(Player)
	for i,v in Player.character:GetChildren() do
		if v:IsA("Accessory") then
			for i2,v2 in pairs(v.Handle:GetChildren()) do
				if v2:IsA("WrapLayer") then
					local refWT = Instance.new("WrapTarget")
					refWT.Parent = v2.Parent
					refWT:Destroy()
					refWT.Parent = nil
				end
			end
		end
	end
end

local function removeGlider(Player)
    for _, Accessory in Player.Character:GetChildren() do
        if Accessory:IsA("Accessory") then
            if CollectionService:HasTag(Accessory, "Glider") then
                Accessory.Parent = workspace
                task.wait(3)
                Accessory:Destroy()
            end
        end
    end
end

function Ragdoll.Client:CreateRagdoll(Player)
    local Model = Player.Character or Player.CharacterAdded:Wait()

    if not Model then return end
    local Humanoid = Model:WaitForChild("Humanoid")

    if Humanoid then
        Humanoid:SetAttribute("Ragdoll", true)
    end

	local Weld = Instance.new("Weld", Model)
	Weld.Part0 = Model:FindFirstChild("HumanoidRootPart")
	Weld.Part1 = Model:FindFirstChild("UpperTorso")

    for _, Table in RagdollLimit.RAGDOLL_RIG do
        local Part = Model:FindFirstChild(Table.motorParentName)
        if not Part then continue end

        Part.CanCollide = true
        Part.Anchored = false
        Part.Massless = false
        
        local Motor = Part:FindFirstChild(Table.motorName)
        local BallSocketConstraint = Instance.new("BallSocketConstraint", Part)
        BallSocketConstraint.Name = Table.motorName

        local A1 = Instance.new("Attachment", Model:FindFirstChild(Table.part0Name))
        local A2 = Instance.new("Attachment", Model:FindFirstChild(Table.part1Name))

        A1.Name = "A1"
        A2.Name = "A2"

        BallSocketConstraint.Attachment0 = A1
        BallSocketConstraint.Attachment1 = A2

        if not Motor:IsA("Motor6D") then
            continue
        end

        A1.CFrame = Motor.C0
        A2.CFrame = Motor.C1

        BallSocketConstraint.LimitsEnabled = true
        BallSocketConstraint.TwistLimitsEnabled = true
        BallSocketConstraint.UpperAngle = Table.limits.UpperAngle
        BallSocketConstraint.TwistUpperAngle = Table.limits.TwistUpperAngle
        BallSocketConstraint.TwistLowerAngle = Table.limits.TwistLowerAngle

        Motor:Destroy()
    end

    local BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(2000, 100, 100)
    BodyGyro.P = 3000
    BodyGyro.D = 1500
    BodyGyro.CFrame = Model.UpperTorso.CFrame

    BodyGyro.Parent = Model.UpperTorso

    Humanoid.EvaluateStateMachine = false

    resyncClothes(Player)
    removeGlider(Player)
    print("Ragdoll created for " .. Player.Name)
    return Model
end

return Ragdoll