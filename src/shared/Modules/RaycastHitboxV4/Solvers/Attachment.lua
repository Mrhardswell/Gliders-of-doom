local solver = {}

function solver:Solve(point: {[string]: any}): (Vector3, Vector3)
	if not point.LastPosition then
		point.LastPosition = point.Instances[1].WorldPosition
	end

	local origin: Vector3 = point.Instances[1].WorldPosition
	local direction: Vector3 = point.Instances[1].WorldPosition - point.LastPosition

	return origin, direction
end

function solver:UpdateToNextPosition(point: {[string]: any}): Vector3
	return point.Instances[1].WorldPosition
end

function solver:Visualize(point: {[string]: any}): CFrame
	return CFrame.lookAt(point.Instances[1].WorldPosition, point.LastPosition)
end

return solver