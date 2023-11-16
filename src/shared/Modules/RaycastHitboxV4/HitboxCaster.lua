
local DEFAULT_ATTACHMENT_INSTANCE: string = "DmgPoint"
local DEFAULT_GROUP_NAME_INSTANCE: string = "Group"

local DEFAULT_DEBUGGER_RAY_DURATION: number = 0 -- 0.25

local DEFAULT_DEBUG_LOGGER_PREFIX: string = "[ Raycast Hitbox V4 ]\n"
local DEFAULT_MISSING_ATTACHMENTS: string = "No attachments found in object: %s. Can be safely ignored if using SetPoints."
local DEFAULT_ATTACH_COUNT_NOTICE: string = "%s attachments found in object: %s."

local MINIMUM_SECONDS_SCHEDULER: number = 1 / 60
local DEFAULT_SIMULATION_TYPE: RBXScriptSignal = game:GetService("RunService").Heartbeat

local CollectionService: CollectionService = game:GetService("CollectionService")
local VisualizerCache = require(script.Parent.VisualizerCache)

local ActiveHitboxes: {[number]: any} = {}
local Solvers: Instance = script.Parent:WaitForChild("Solvers")

local Hitbox = {}
Hitbox.__index = Hitbox
Hitbox.__type = "RaycastHitbox"

Hitbox.CastModes = {
	LinkAttachments = 1,
	Attachment = 2,
	Vector3 = 3,
	Bone = 4,
}
type Point = {
	Group: string?,
	CastMode: number,
	LastPosition: Vector3?,
	WorldSpace: Vector3?,
	Instances: {[number]: Instance | Vector3}
}

type AdornmentData = VisualizerCache.AdornmentData

function Hitbox:HitStart(seconds: number?)
	if self.HitboxActive then
		self:HitStop()
	end

	if seconds then
		self.HitboxStopTime = os.clock() + math.max(MINIMUM_SECONDS_SCHEDULER, seconds)
	end

	self.HitboxActive = true
end

function Hitbox:HitStop()
	self.HitboxActive = false
	self.HitboxStopTime = 0
	table.clear(self.HitboxHitList)
end

function Hitbox:Destroy()
	self.HitboxPendingRemoval = true

	if self.HitboxObject then
		CollectionService:RemoveTag(self.HitboxObject, self.Tag)
	end

	self:HitStop()
	self.OnHit:Destroy()
	self.OnUpdate:Destroy()
	self.HitboxRaycastPoints = nil
	self.HitboxObject = nil
end

function Hitbox:Recalibrate()
	local descendants: {[number]: Instance} = self.HitboxObject:GetDescendants()
	local attachmentCount: number = 0

	for i = #self.HitboxRaycastPoints, 1, -1 do
		if self.HitboxRaycastPoints[i].CastMode == Hitbox.CastModes.Attachment then
			table.remove(self.HitboxRaycastPoints, i)
		end
	end

	for _, attachment: any in ipairs(descendants) do
		if not attachment:IsA("Attachment") or attachment.Name ~= DEFAULT_ATTACHMENT_INSTANCE then
			continue
		end

		local group: string? = attachment:GetAttribute(DEFAULT_GROUP_NAME_INSTANCE)
		local point: Point = self:_CreatePoint(group, Hitbox.CastModes.Attachment, attachment.WorldPosition)

		table.insert(point.Instances, attachment)
		table.insert(self.HitboxRaycastPoints, point)

		attachmentCount += 1
	end

	if false then -- self.DebugLog then
		print(string.format("%s%s", DEFAULT_DEBUG_LOGGER_PREFIX,
			attachmentCount > 0 and string.format(DEFAULT_ATTACH_COUNT_NOTICE, attachmentCount, self.HitboxObject.Name) or
				string.format(DEFAULT_MISSING_ATTACHMENTS, self.HitboxObject.Name))
		)
	end
end

function Hitbox:LinkAttachments(attachment1: Attachment, attachment2: Attachment)
	local group: string? = attachment1:GetAttribute(DEFAULT_GROUP_NAME_INSTANCE)
	local point: Point = self:_CreatePoint(group, Hitbox.CastModes.LinkAttachments)

	point.Instances[1] = attachment1
	point.Instances[2] = attachment2
	table.insert(self.HitboxRaycastPoints, point)
end

function Hitbox:UnlinkAttachments(attachment: Attachment)
	for i = #self.HitboxRaycastPoints, 1, -1 do
		if #self.HitboxRaycastPoints[i].Instances >= 2 then
			if self.HitboxRaycastPoints[i].Instances[1] == attachment or self.HitboxRaycastPoints[i].Instances[2] == attachment then
				table.remove(self.HitboxRaycastPoints, i)
			end
		end
	end
end

function Hitbox:SetPoints(object: BasePart | Bone, vectorPoints: {[number]: Vector3}, group: string?)
	for _: number, vector: Vector3 in ipairs(vectorPoints) do
		local point: Point = self:_CreatePoint(group, Hitbox.CastModes[object:IsA("Bone") and "Bone" or "Vector3"])

		point.Instances[1] = object
		point.Instances[2] = vector
		table.insert(self.HitboxRaycastPoints, point)
	end
end

function Hitbox:RemovePoints(object: BasePart | Bone, vectorPoints: {[number]: Vector3})
	for i = #self.HitboxRaycastPoints, 1, -1 do
		local part = (self.HitboxRaycastPoints[i] :: Point).Instances[1]

		if part == object then
			local originalVector = (self.HitboxRaycastPoints[i] :: Point).Instances[2]

			for _: number, vector: Vector3 in ipairs(vectorPoints) do
				if vector == originalVector :: Vector3 then
					table.remove(self.HitboxRaycastPoints, i)
					break
				end
			end
		end
	end
end

function Hitbox:_CreatePoint(group: string?, castMode: number, lastPosition: Vector3?): Point
	return {
		Group = group,
		CastMode = castMode,
		LastPosition = lastPosition,
		WorldSpace = nil,
		Instances = {},
	}
end

function Hitbox:_FindHitbox(object: any)
	for _: number, hitbox: any in ipairs(ActiveHitboxes) do
		if not hitbox.HitboxPendingRemoval and hitbox.HitboxObject == object then
			return hitbox
		end
	end
end

function Hitbox:_Init()
	if not self.HitboxObject then return end

	local tagConnection: RBXScriptConnection

	local function onTagRemoved(instance: Instance)
		if instance == self.HitboxObject then
			tagConnection:Disconnect()
			self:Destroy()
		end
	end

	self:Recalibrate()
	table.insert(ActiveHitboxes, self)
	CollectionService:AddTag(self.HitboxObject, self.Tag)
	tagConnection = CollectionService:GetInstanceRemovedSignal(self.Tag):Connect(onTagRemoved)
end

local function Init()
	local solversCache: {[number]: any} = table.create(#Solvers:GetChildren())

	DEFAULT_SIMULATION_TYPE:Connect(function(step: number)

		for i = #ActiveHitboxes, 1, -1 do

			if ActiveHitboxes[i].HitboxPendingRemoval then
				local hitbox: any = table.remove(ActiveHitboxes, i)
				table.clear(hitbox)
				setmetatable(hitbox, nil)
				continue
			end

			for _: number, point: Point in ipairs(ActiveHitboxes[i].HitboxRaycastPoints) do

				if not ActiveHitboxes[i].HitboxActive then
					point.LastPosition = nil
					continue
				end

				local castMode: any = solversCache[point.CastMode]
				local origin: Vector3, direction: Vector3 = castMode:Solve(point)
				local raycastResult: RaycastResult = workspace:Raycast(origin, direction, ActiveHitboxes[i].RaycastParams)

				if ActiveHitboxes[i].Visualizer then
					local adornmentData: AdornmentData? = VisualizerCache:GetAdornment()

					if adornmentData then
						local debugStartPosition: CFrame = castMode:Visualize(point)
						adornmentData.Adornment.Length = direction.Magnitude
						adornmentData.Adornment.CFrame = debugStartPosition
					end
				end

				point.LastPosition = castMode:UpdateToNextPosition(point)

				if raycastResult then
					local part: BasePart = raycastResult.Instance
					local model: Instance?
					local humanoid: Instance?
					local target: Instance?

					if ActiveHitboxes[i].DetectionMode == 1 then
						model = part:FindFirstAncestorOfClass("Model")
						if model then
							humanoid = model:FindFirstChildOfClass("Humanoid")
						end
						target = humanoid
					else
						target = part
					end

					if target then
						if ActiveHitboxes[i].DetectionMode <= 2 then
							if ActiveHitboxes[i].HitboxHitList[target] then
								continue
							else
								ActiveHitboxes[i].HitboxHitList[target] = true
							end
						end

						ActiveHitboxes[i].OnHit:Fire(part, humanoid, raycastResult, point.Group)
					end
				end

				if ActiveHitboxes[i].HitboxStopTime > 0 then
					if ActiveHitboxes[i].HitboxStopTime <= os.clock() then
						ActiveHitboxes[i]:HitStop()
					end
				end

				ActiveHitboxes[i].OnUpdate:Fire(point.LastPosition)

				if ActiveHitboxes[i].OnUpdate._signalType ~= ActiveHitboxes[i].SignalType then
					ActiveHitboxes[i].OnUpdate._signalType = ActiveHitboxes[i].SignalType
					ActiveHitboxes[i].OnHit._signalType = ActiveHitboxes[i].SignalType
				end
			end
		end

		local adornmentsInUse: number = #VisualizerCache._AdornmentInUse

		if adornmentsInUse > 0 then
			for i = adornmentsInUse, 1, -1 do
				if (os.clock() - VisualizerCache._AdornmentInUse[i].LastUse) >= DEFAULT_DEBUGGER_RAY_DURATION then
					local adornment: AdornmentData? = table.remove(VisualizerCache._AdornmentInUse, i)

					if adornment then
						VisualizerCache:ReturnAdornment(adornment)
					end
				end
			end
		end
	end)

	for castMode: string, enum: number in pairs(Hitbox.CastModes) do
		local moduleScript: Instance? = Solvers:FindFirstChild(castMode)

		if moduleScript then
			local load = require(moduleScript)
			solversCache[enum] = load
		end
	end
end

Init()

return Hitbox