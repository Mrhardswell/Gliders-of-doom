local solver = {}

local EMPTY_VECTOR: Vector3 = Vector3.new()

function solver:Solve(point: {[string]: any}): (Vector3, Vector3)

	local originBone: Bone = point.Instances[1]
	local vector: Vector3 = point.Instances[2]
	local worldCFrame: CFrame = originBone.TransformedWorldCFrame
	local pointToWorldSpace: Vector3 = worldCFrame.Position + worldCFrame:VectorToWorldSpace(vector)

	if not point.LastPosition then
		point.LastPosition = pointToWorldSpace
	end

	local origin: Vector3 = point.LastPosition
	local direction: Vector3 = pointToWorldSpace - (point.LastPosition or EMPTY_VECTOR)

	point.WorldSpace = pointToWorldSpace

	return origin, direction
end

function solver:UpdateToNextPosition(point: {[string]: any}): Vector3
	return point.WorldSpace
end

function solver:Visualize(point: {[string]: any}): CFrame
	return CFrame.lookAt(point.WorldSpace, point.LastPosition)
end

return solver