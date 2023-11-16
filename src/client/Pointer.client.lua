local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local CurrentTarget = Instance.new("ObjectValue")
local SelectionBox = Instance.new("SelectionBox")

local SelectionBoxColor = Color3.fromRGB(93, 255, 220)

SelectionBox.Color3 = SelectionBoxColor

local Effect = ReplicatedStorage.Assets.Effects.Hit:Clone()
Effect.Parent = workspace
Effect.Transparency = 1

local EffectPart = Instance.new("ObjectValue")
EffectPart.Name = "EffectPart"
EffectPart.Parent = Player
EffectPart.Value = Effect

CurrentTarget.Parent = Player
CurrentTarget.Name = "CurrentTarget"

UserInputService.InputChanged:Connect(function(Input, Prossesed)
	if Input.UserInputType == Enum.UserInputType.MouseMovement then
		if Mouse.Target then
			if not Player.Character then return end
			local Magnitude = (Mouse.Target.Position - Player.Character.HumanoidRootPart.Position).Magnitude
			if Magnitude > 10 then
				CurrentTarget.Value = nil
				return
			end
			if CollectionService:HasTag(Mouse.Target, "Block") then
				CurrentTarget.Value = Mouse.Target
			else
				CurrentTarget.Value = nil
			end
		else
			CurrentTarget.Value = nil
		end
		if Mouse.Hit then
			Effect.CFrame = CFrame.new(Mouse.Hit.Position)
		end
	end
end)

local BlockGui = workspace:FindFirstChild("BlockGui")

CurrentTarget.Changed:Connect(function()
	if CurrentTarget.Value then
		SelectionBox.Adornee = CurrentTarget.Value
		SelectionBox.Parent = CurrentTarget.Value
		local Health = tonumber(CurrentTarget.Value:GetAttribute("Health"))
		local Max = tonumber(CurrentTarget.Value:GetAttribute("MaxHealth"))
		BlockGui.Adornee = CurrentTarget.Value
		BlockGui.Main.Amount.Text = Health .. "/" .. Max
		BlockGui.Main.Indicator.Size = UDim2.new(Health / Max, 0, 1, 0)
		BlockGui.Main.Indicator.BackgroundColor3 = Color3.fromHSV(Health / Max * 0.35, 1, 1)
		SelectionBox.Color3 = Color3.fromHSV(Health / Max * 0.35, 1, 1)
	else
		SelectionBox.Adornee = nil
		SelectionBox.Parent = nil
		BlockGui.Adornee = nil
		BlockGui.Main.Amount.Text = ""
	end
end)
