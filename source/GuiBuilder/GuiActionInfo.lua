local GuiActionInfo = {
	ShowElement = {
		name = "string", 
		elementToShow = "instance",
		["func"] = function(args)
			args.elementToShow.Visible = true
		end
	},
	HideElement = {
		name = "string", 
		elementToHide = "instance",
		["func"] = function(args)
			args.elementToHide.Visible = false
		end
	},
	ToggleElementVisibility = {
		name = "string", 
		elementToToggle = "instance",
		["func"] = function(args)
			args.elementToToggle.Visible = not args.elementToToggle.Visible
		end
	},
	SetSize = {
		name = "string",
		Element = "instance",
		["xScale"] = "number",
		["xOffset"] = "number",
		["yScale"] = "number",
		["yOffset"] = "number",
		["func"] = function(args)
			args.Element.Size = UDim2.new(args.xScale, args.xOffset, args.yScale, args.yOffset)
		end
	},
	SetPosition = {
		name = "string",
		Element = "instance",
		["xScale"] = "number",
		["xOffset"] = "number",
		["yScale"] = "number",
		["yOffset"] = "number",
		["func"] = function(args)
			args.Element.Position = UDim2.new(args.xScale, args.xOffset, args.yScale, args.yOffset)
		end
	},
	TweenSize = {
		name = "string",
		ElementToTween = "instance",
		EasingStyle = "string",
		EasingDirection = "string",
		RepeatCount = "number",
		DelayTime = "number",
		["Time"] = "number",
		["xScale"] = "number",
		["xOffset"] = "number",
		["yScale"] = "number",
		["yOffset"] = "number",
		["func"] = function(args)
			local tween = game:GetService("TweenService"):Create(
				args.ElementToTween, 
				TweenInfo.new(
					args.Time, 
					Enum.EasingStyle[args.EasingStyle], 
					Enum.EasingDirection[args.EasingDirection],
					args.RepeatCount,
					false,
					args.DelayTime
				),
				{Size = UDim2.new(args.xScale, args.xOffset, args.yScale, args.yOffset)}
			)
			tween:Play()
		end
	},
	TweenPosition = {
		name = "string",
		ElementToTween = "instance",
		EasingStyle = "string",
		EasingDirection = "string",
		RepeatCount = "number",
		DelayTime = "number",
		["Time"] = "number",
		["xScale"] = "number",
		["xOffset"] = "number",
		["yScale"] = "number",
		["yOffset"] = "number",
		["func"] = function(args)
			local tween = game:GetService("TweenService"):Create(
				args.ElementToTween, 
				TweenInfo.new(
					args.Time, 
					Enum.EasingStyle[args.EasingStyle], 
					Enum.EasingDirection[args.EasingDirection],
					args.RepeatCount,
					false,
					args.DelayTime
				),
				{Position = UDim2.new(args.xScale, args.xOffset, args.yScale, args.yOffset)}
			)
			tween:Play()
		end
	},
	SetBackgroundColor3 = {
		name = "string",
		Element = "instance",
		R = "number",
		G = "number",
		B = "number",
		["func"] = function(args)
			args.Element.BackgroundColor3 = Color3.fromRGB(args.R, args.G, args.B)
		end
	},
	SetText = {
		name = "string",
		Element = "instance",
		Text = "string",
		["func"] = function(args)
			if args.Element.Text then
				args.Element.Text = args.Text
			else
				error("GuiBuilder: SetText 'Element' must be set to a TextLabel, TextButton, or TextBox")
			end
		end
	},
	SetTextColor3 = {
		name = "string",
		Element = "instance",
		R = "number",
		G = "number",
		B = "number",
		["func"] = function(args)
			if args.Element.Text then
				args.Element.TextColor3 = Color3.fromRGB(args.R, args.G, args.B)
			else
				error("GuiBuilder: SetTextColor3 'Element' must be set to a TextLabel, TextButton, or TextBox")
			end
		end
	},
	SetImage = {
		name = "string",
		Element = "instance",
		AssetId = "number",
		["func"] = function(args)
			if args.Element.Image then
				args.Element.Image = "rbxassetid://".. tostring(args.AssetId)
			else
				error("GuiBuilder: SetImage 'Element' must be set to an ImageLabel or ImageButton")
			end
		end
	},
	SetImageColor3 = {
		name = "string",
		Element = "instance",
		R = "number",
		G = "number",
		B = "number",
		["func"] = function(args)
			if args.Element.Image then
				args.Element.ImageColor3 = Color3.fromRGB(args.R, args.G, args.B)
			else
				error("GuiBuilder: SetImageColor3 'Element' must be set to an ImageLabel or ImageButton")
			end
		end
	},
}

return GuiActionInfo