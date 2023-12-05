local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local isVR = UserInputService.VREnabled

local Knit = require(ReplicatedStorage.Packages.Knit)
local Net = require(ReplicatedStorage.Packages.Net)
local Util = require(script.Util)
local Config = require(script.Config)
local FpsCamera = require(script.FpsCamera)

local setLookAngles = Net:RemoteEvent("SetLookAngles")

local XZ_VECTOR3 = Vector3.new(1, 0, 1)

local CharacterRealism = Knit.CreateController {
    Name = "Realism_Controller";
    Rotators = {};
	BindTag = "RealismHook";
	Player = Players.LocalPlayer;
	SetLookAngles = setLookAngles;
 }

function CharacterRealism:Connect(funcName, event)
	return event:Connect(function (...)
		self[funcName](self, ...)
	end)
end

function CharacterRealism:AddMotor(rotator, motor)
	local parent = motor.Parent
	
	if parent and parent.Name == "Head" then
		parent.CanCollide = false
	end

	Util:PromiseValue(motor, "Active", function ()

		local data =
		{
			Motor = motor;
			C0 = motor.C0;
		}

		Util:PromiseChild(motor.Part0, motor.Name .. "RigAttachment", function (origin)
			if origin:IsA("Attachment") then
				data.Origin = origin
				data.C0 = nil
			end
		end)

		local id = motor.Part1.Name
		rotator.Motors[id] = data
	end)
end

function CharacterRealism:OnLookReceive(player, pitch, yaw)

	local character = player.Character
	local rotator = self.Rotators[character]
	
	if rotator then
		rotator.Pitch.Goal = pitch
		rotator.Yaw.Goal = yaw
	end

end

function CharacterRealism:ComputeLookAngle(lookVector, useDir)

	local inFirstPerson = FpsCamera:IsInFirstPerson()
	local pitch, yaw, dir = 0, 0, 1

	if not lookVector then
		local camera = workspace.CurrentCamera
		lookVector = camera.CFrame.LookVector
	end

	if lookVector then

		local character = self.Player.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")

		if rootPart and rootPart:IsA("BasePart") then
			local cf = rootPart.CFrame
			pitch = -cf.RightVector:Dot(lookVector)

			if not inFirstPerson then
				dir = math.clamp(cf.LookVector:Dot(lookVector) * 10, -1, 1)
			end
		end

		yaw = lookVector.Y
	end

	if useDir then
		dir = useDir
	end

	pitch *= dir
	yaw *= dir

	return pitch, yaw
end

function CharacterRealism:StepValue(state, delta)
	local current = state.Current or 0
	local goal = state.Goal

	local pan = 5 / (delta * 60)
	local rate = math.min(1, (delta * 20) / 3)

	local step = math.min(rate, math.abs(goal - current) / pan)
	state.Current = Util:StepTowards(current, goal, step)

	return state.Current
end

function CharacterRealism:UpdateLookAngles(Interval)

	if isVR then
		return
	end



	local pitch, yaw = self:ComputeLookAngle()
	self:OnLookReceive(self.Player, pitch, yaw)

	local lastUpdate = self.LastUpdate or 0
	local now = os.clock()

	if (now - lastUpdate) > .5 then
		pitch = Util:RoundNearestInterval(pitch, .05)
		yaw = Util:RoundNearestInterval(yaw, .05)

		if pitch ~= self.Pitch then
			self.Pitch = pitch
			self.Dirty = true
		end

		if yaw ~= self.Yaw then
			self.Yaw = yaw
			self.Dirty = true
		end
		
		if self.Dirty then
			self.Dirty = false
			self.LastUpdate = now

			if not isVR then
				self.SetLookAngles:FireServer(pitch, yaw)
			end

		end
	end

	local camera = workspace.CurrentCamera
	local camPos = camera.CFrame.Position
	
	local player = self.Player
	local dropList
	
	for character, rotator in self.Rotators do
		if not character.Parent then
			if not dropList then
				dropList = {}
			end
			
			dropList[character] = true
			continue
		end
		
		local owner = Players:GetPlayerFromCharacter(character)
		local dist = owner and owner:DistanceFromCharacter(camPos) or 0

		if owner ~= player and dist > 30 then
			continue
		end
		
		local lastStep = rotator.LastStep or 0
		local stepDelta = now - lastStep

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rootPart = humanoid and humanoid.RootPart

		if not rootPart then
			continue
		end
		
		local pitchState = rotator.Pitch
		self:StepValue(pitchState, stepDelta)

		local yawState = rotator.Yaw
		self:StepValue(yawState, stepDelta)
		
		local motors = rotator.Motors
		rotator.LastStep = now
		
		if not motors then
			continue
		end
		
		for name, factors in pairs(self.RotationFactors) do
			local data = motors and motors[name]

			if not data then
				continue
			end

			local motor = data.Motor
			local origin = data.Origin
			
			if origin then
				local part0 = motor.Part0
				local setPart0 = origin.Parent
				
				if part0 and part0 ~= setPart0 then
					local newOrigin = part0:FindFirstChild(origin.Name)

					if newOrigin and newOrigin:IsA("Attachment") then
						origin = newOrigin
						data.Origin = newOrigin
					end
				end
				
				origin = origin.CFrame
			elseif data.C0 then
				origin = data.C0
			else
				continue
			end

			local pitch = pitchState.Current or 0
			local yaw = yawState.Current or 0

			if rotator.SnapFirstPerson and name == "Head" then
				if FpsCamera:IsInFirstPerson() then
					pitch = pitchState.Goal
					yaw = yawState.Goal
				end
			end

			local fPitch = pitch * factors.Pitch
			local fYaw = yaw * factors.Yaw

			if name:sub(-4) == " Arm" or name:sub(-8) == "UpperArm" then
				local tool = character:FindFirstChildOfClass("Tool")
				
				if tool and not CollectionService:HasTag(tool, "NoArmRotation") then
					if name:sub(1, 5) == "Right" and rootPart:GetRootPart() ~= rootPart then
						fPitch = pitch * 1.3
						fYaw = yaw * 1.3
					else
						fYaw = yaw * .8
					end
				end
			end

			local dirty = false

			if fPitch ~= pitchState.Value then
				pitchState.Value = fPitch
				dirty = true
			end

			if fYaw ~= yawState.Value then
				yawState.Value = fYaw
				dirty = true
			end

			if dirty then
				local rot = origin - origin.Position
				
				local cf = CFrame.Angles(0, fPitch, 0)
				         * CFrame.Angles(fYaw, 0, 0)

				local TargetCFrame = origin * rot:Inverse() * cf * rot
				motor.C0 = TargetCFrame

			end
		end
	end

	if dropList then
		for character in pairs(dropList) do
			local rotator = self.Rotators[character]
			local listener = rotator and rotator.Listener
			
			if listener then
				listener:Disconnect()
			end
			
			self.Rotators[character] = nil
		end
	end
end

function CharacterRealism:MountLookAngle(humanoid)
	local character = humanoid.Parent
	local rotator = character and self.Rotators[character]
	
	if not rotator then
		rotator = 
		{
			Motors = {};
			
			Pitch =
			{
				Goal = 0;
				Current = 0;
			};

			Yaw =
			{
				Goal = 0;
				Current = 0;
			};
		}
		
		local player = Players:GetPlayerFromCharacter(character)
		
		if player == self.Player then
			rotator.SnapFirstPerson = true
		end

		self.Rotators[character] = rotator
		
		local function onDescendantAdded(desc)
			if desc:IsA("Motor6D") then
				self:AddMotor(rotator, desc)
			end
		end
		
		for _, desc in character:GetDescendants() do
			onDescendantAdded(desc)
		end
		
		rotator.Listener = character.DescendantAdded:Connect(onDescendantAdded)
	end
	
	return rotator
end

function CharacterRealism:MountMaterialSounds(humanoid)
	local character = humanoid.Parent
	local rootPart = character and character:WaitForChild("HumanoidRootPart", 10)

	if not (rootPart and rootPart:IsA("BasePart")) then
		return
	end

	Util:PromiseChild(rootPart, "Running", function (running)
		if not running:IsA("Sound") then
			return
		end

		local oldPitch = Instance.new("NumberValue")
		oldPitch.Name = "OldPitch"
		oldPitch.Parent = running
		oldPitch.Value = 1

		local function onStateChanged(old, new)			
			if new.Name:find("Running") then
				while humanoid:GetState() == new do
					local hipHeight = humanoid.HipHeight
					
					if humanoid.RigType.Name == "R6" then
						hipHeight = 2.8
					end
					
					local scale = hipHeight / 3
					local speed = (rootPart.Velocity * XZ_VECTOR3).Magnitude
					
					local volume = ((speed - 4) / 12) * scale
					running.Volume = math.clamp(volume, 0, 1)
					
					local pitch = oldPitch.Value / ((scale * 15) / speed)
					running.Pitch = pitch
					
					RunService.Heartbeat:Wait()
				end	
			end
		end
		
		local function updateRunningSoundId()
			local soundId = self.Sounds.Concrete
			local material = humanoid.FloorMaterial.Name
			
			if not self.Sounds[material] then
				material = self.MaterialMap[material]
			end
			
			if self.Sounds[material] then
				soundId = self.Sounds[material]
			end
			
			running.SoundId = "rbxassetid://" .. soundId
		end
		
		local floorListener = humanoid:GetPropertyChangedSignal("FloorMaterial")
		floorListener:Connect(updateRunningSoundId)
		
		running.EmitterSize = 1
		running.MaxDistance = 50
		
		updateRunningSoundId()
		humanoid.StateChanged:Connect(onStateChanged)
		
		onStateChanged(nil, Enum.HumanoidStateType.Running)
	end)
end

function CharacterRealism:OnHumanoidAdded(humanoid)
	if humanoid:IsA("Humanoid") then
		if not self.SkipLookAngle then
			self:MountLookAngle(humanoid)
		end
		
		if not self.SkipMaterialSounds then
			self:MountMaterialSounds(humanoid)
		end
	end
end

function CharacterRealism:KnitStart()
	assert(not _G.DefineRealismClient, "Realism can only be started once on the client!")

	_G.DefineRealismClient = true

	for key, value in Config do
		self[key] = value
	end
	
	for _, humanoid in CollectionService:GetTagged(self.BindTag) do
		self:OnHumanoidAdded(humanoid)
	end

	self:Connect("UpdateLookAngles", RunService.Heartbeat)
	self:Connect("OnLookReceive", self.SetLookAngles.OnClientEvent)
	self:Connect("OnHumanoidAdded", CollectionService:GetInstanceAddedSignal(self.BindTag))

	FpsCamera:Start()

end

return CharacterRealism