local TweenInfos = {}

TweenInfos = {
	["Default"] = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	["Slow"] = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	["Fast"] = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	["Instant"] = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),

	["FastBack"] = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	["Elastic"] = TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
	["Bounce"] = TweenInfo.new(.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),

	["Looping"] = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1),

	["Quint"] = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	["Quart"] = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	["Quad"] = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	["Cubic"] = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
	["Circ"] = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
	["Back"] = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

	["Looping_Slow"] = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1),
	["Looping_Fast"] = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1),
	["Looping_Instant"] = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1),

	["Buttons"] = TweenInfo.new(0.1, Enum.EasingStyle.Sine,Enum.EasingDirection.In, 0, true)
}

return TweenInfos