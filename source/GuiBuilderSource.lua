local CollectionService = game:GetService("CollectionService")

local GuiActionInfo
local GuiAction = require(script.Parent.GuiAction)
local StudioWidgets = require(2393391735)
	local CollapsibleTitledSection = StudioWidgets.CollapsibleTitledSection
	local GuiUtilities = StudioWidgets.GuiUtilities
	local ImageButtonWithText = StudioWidgets.ImageButtonWithText
	local LabeledCheckBox = StudioWidgets.LabeledCheckbox
	local LabeledMultiChoice = StudioWidgets.LabeledMultiChoice
	local LabeledSlider = StudioWidgets.LabeledSlider
	local LabeledTextInput = StudioWidgets.LabeledTextInput
	local StatefulImageButton = StudioWidgets.StatefulImageButton
	local VerticallyScalingListFrame = StudioWidgets.VerticallyScalingListFrame
	local CustomTextButton = StudioWidgets.CustomTextButton
	local LabeledRadioButton = StudioWidgets.LabeledRadioButton
	local RbxGui = StudioWidgets.RbxGui
	local AutoScalingScrollingFrame = StudioWidgets.AutoScalingScrollingFrame

function CreateDockWidget(guiId, title, initDockState, initEnabled, overrideEnabledRestore, floatXSize, floatYSize, minWidth, minHeight)
	local DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui(
		guiId,
		DockWidgetPluginGuiInfo.new(
		initDockState,
		initEnabled,
		overrideEnabledRestore,
		floatXSize, 
		floatYSize,
		minWidth,
		minHeight
		)
	)
	DockWidgetPluginGui.Title = title
	return DockWidgetPluginGui
end

function clearFrame(frame)
	for _, v in pairs(frame:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end
end

function delimitActionInputString(actionInputString)
	local event, action = actionInputString:match("([^,]+),([^,]+)")
	return event, action
end

function ParseGuiObject(obj)
	
	local function parseProperties(e) -- returns the table of Events for generic gui element "e"
		local t = {}
		if e:IsA("GuiButton") then
			for i = 1, #Events.GuiButton do
				t[#t + 1] = Events.GuiButton[i]
			end
		elseif e:IsA("TextBox") then
			for i = 1, #Events.TextBox do
				t[#t + 1] = Events.TextBox[i]
			end
		end
		for i = 1, #Events.GuiObject do
			t[#t + 1] = Events.GuiObject[i]
		end
		return t
	end
	
	if not obj:IsA("GuiObject") then
		return {}
	end
	
	return parseProperties(obj)
end
	
function createGuiAction(element, event, funcName, params)	
	local guiAction, inputActionContainer = GuiAction.new(element, event, funcName, params)	
	return inputActionContainer
end

function updateGuiAction(elementBin, setParams)
	for parameter, value in pairs(setParams) do
		elementBin[parameter].Value = value
	end
end

local function getDictionarySize(t)
	local counter = 0
	for i, v in pairs(t) do
		if typeof(v) ~= "function" then
			counter = counter + 1
		end
	end
	return counter
end

Events = {
	["GuiObject"] = {
		"InputBegan",
		"InputChanged",
		"InputEnded",
		"MouseEnter",
		"MouseLeave",
		"MouseMoved",
		"MouseWheelBackward",
		"MouseWheelForward",
		"SelectionGained",
		"SelectionLost",
		"TouchLongPress",
		"TouchPan",
		"TouchPinch",
		"TouchRotate",
		"TouchSwipe",
		"TouchTap"
	},
	["GuiButton"] = {
		"MouseButton2Up",
		"MouseButton2Down",
		"MouseButton2Click",
		"MouseButton1Up",
		"MouseButton1Down",
		"MouseButton1Click",
		"Activated"
	},
	["TextBox"] = {
		"FocusLost",
		"Focused"
	}
}

main = function()
	
	if not game.ReplicatedStorage:FindFirstChild("GuiBuilder") then
		local bin = script.Parent.GuiBuilder:Clone()
		bin.Parent = game.ReplicatedStorage		
	end
	GuiActionInfo = require(game.ReplicatedStorage.GuiBuilder.GuiActionInfo)
	
	if not game.StarterPlayer:WaitForChild("StarterPlayerScripts"):FindFirstChild("GuiBuilderClient") and (plugin:GetSetting("AutoRequire") == nil or plugin:GetSetting("AutoRequire") == true) then
		local ls = script.Parent.GuiBuilderClient:Clone()
		ls.Parent = game.StarterPlayer.StarterPlayerScripts
		ls.Disabled = false
	end
	
	local canCreateWindow = true
	local isInInstanceSelection = false
	
	local function getSelection()
		local t = game.Selection:Get()
		local counter = 0
		local obj
		for i, v in pairs(t) do
			counter = counter + 1
			obj = v
		end
		if counter == 1 then
			return obj
		end
	end
	
	local Toolbar = plugin:CreateToolbar("GuiBuilder")
	local BuilderWindow = Toolbar:CreateButton("Editor", "Opens the GuiBuilder editor menu", "http://www.roblox.com/asset/?id=2405211207")
	local RefreshGuiActions = Toolbar:CreateButton("Refresh GuiActions", "Refreshes the list of available GuiActions", "rbxassetid://1507949215")
	local Settings = Toolbar:CreateButton("Settings", "Opens the settings menu", "rbxassetid://1507949215")
	local DockWidgetPluginGui = CreateDockWidget("GuiBuilder", "GuiBuilderEditor", Enum.InitialDockState.Float, true, true, 150, 150, 150, 150)
	DockWidgetPluginGui.Enabled = false
	
	local InputList = VerticallyScalingListFrame.new("InputList")
	local InputFrame = AutoScalingScrollingFrame.new("InputFrame", InputList._uiListLayout)
	local InputSection = CollapsibleTitledSection.new("Inputs", "No element selected!", true, false, false)
	InputFrame:GetFrame().Size = UDim2.new(1, 0, 0.5, 0)
	InputFrame:GetFrame().Parent = DockWidgetPluginGui
	InputList:GetFrame().Parent = InputSection:GetContentsFrame()
	InputSection:GetSectionFrame().Parent = InputFrame:GetFrame()
	
	local ActionList = VerticallyScalingListFrame.new("ActionList")
	local ActionFrame = AutoScalingScrollingFrame.new("ActionFrame", ActionList._uiListLayout)
	local ActionSection = CollapsibleTitledSection.new("Actions", "No element selected!", true, false, false)
	ActionFrame:GetFrame().Size = UDim2.new(1, 0, 0.5, 0)
	ActionFrame:GetFrame().Position = UDim2.new(0, 0, 0.5, 0)
	ActionFrame:GetFrame().Parent = DockWidgetPluginGui
	ActionList:GetFrame().Parent = ActionSection:GetContentsFrame()
	ActionSection:GetSectionFrame().Parent = ActionFrame:GetFrame()
	
	function updateActionFrame(selectedObj, event)
		ActionSection._frame.TitleBarVisual.TitleLabel.Text = "Actions: " .. event
		clearFrame(ActionList:GetFrame())
		for action, parameters in pairs(GuiActionInfo) do
			local actionTitle = CollapsibleTitledSection.new(action, action, true, false, false)
			local paramList = VerticallyScalingListFrame.new("actionTitleList")
			local actionCreationButton = CustomTextButton.new("Create", "Create")
			actionCreationButton:getButton().Size = UDim2.new(0.5, 0, 0, 20)
			paramList:AddChild(actionCreationButton:getButton())
			ActionList:AddChild(actionTitle:GetSectionFrame())
			ActionList:AddChild(paramList:GetFrame())
			actionCreationButton:getButton().MouseButton1Down:connect(function()
				createParameterWindow(selectedObj, action, event, parameters, paramList)
			end)
			for _, inputActionContainer in pairs(selectedObj:GetChildren()) do
				if inputActionContainer:IsA("Folder") then
					local loadedevent, loadedaction = delimitActionInputString(inputActionContainer.Name)
					if loadedaction == action and loadedevent == event then
						createActionButton(selectedObj, loadedaction, loadedevent, GuiActionInfo[action], paramList, inputActionContainer)
					end
				end
			end
		end
	end
	
	function updateInputFrame(selectedObj)
		clearFrame(InputList:GetFrame())
		local events = ParseGuiObject(selectedObj)
		InputSection._frame.TitleBarVisual.TitleLabel.Text = "Inputs: " .. selectedObj.Name
		for i = 1, #events do
			local button = CustomTextButton.new(events[i], events[i])
			button:getButton().Size = UDim2.new(1, 0, 0, 20)
			InputList:AddChild(button:getButton())
			for _, v in pairs(selectedObj:GetChildren()) do
				local loadedevent, loadedaction = delimitActionInputString(v.Name)
				if v:IsA("Folder") and loadedevent == events[i] then
					button:ToggleState()
					break
				end
			end
			button:getButton().MouseButton1Click:connect(function()
				updateActionFrame(selectedObj, events[i])
			end)
		end
	end
	
	function createActionButton(selectedobj, action, event, parameters, paramList, inputActionContainer)
		if canCreateWindow then
			local button = CustomTextButton.new(action, (inputActionContainer and inputActionContainer:FindFirstChild("name")) and inputActionContainer.name.Value or action)
			local deleteButton = CustomTextButton.new("delete", "x")
			button:getButton().Size = UDim2.new(1, -60, 0, 20)
			deleteButton:getButton().Size = UDim2.new(0, 20, 0, 20)
			deleteButton:getButton().Position = UDim2.new(1, 0, 0, 0)
			deleteButton:getButton().Parent = button:getButton()
			paramList:AddChild(button:getButton())
			button:getButton().MouseButton1Click:connect(function()
				createParameterWindow(selectedobj, action, event, parameters, nil, inputActionContainer)
			end)
			deleteButton:getButton().MouseButton1Click:connect(function()
				if inputActionContainer then
					for i, v in pairs(inputActionContainer:GetChildren()) do
						if v:IsA("ObjectValue") then
							CollectionService:RemoveTag(v.Value, "ActionBoundElement")
						end
					end
					inputActionContainer:Destroy()
					button:getButton():Destroy()
					if not selectedobj:FindFirstChildWhichIsA("Folder") then
						CollectionService:RemoveTag(selectedobj, "ActionAssignedElement")
					end
					updateInputFrame(selectedobj)
				end
			end)
			return button
		end
	end
	
	function createStringParameterInput(parameter, setParams, parameterList, loadedParam, okButton, okButtonFunction)
		local textbox = LabeledTextInput.new(parameter, parameter, loadedParam or "(none)")
		textbox:SetValueChangedFunction(function()
			setParams[parameter] = textbox:GetValue()
		end)
		parameterList:AddChild(textbox:GetFrame())
	end
	
	function createNumberParameterInput(parameter, setParams, parameterList, loadedParam, okButton, okButtonFunction)
		local textbox = LabeledTextInput.new(parameter, parameter, loadedParam or "0")
		textbox:SetValueChangedFunction(function()
			setParams[parameter] = tonumber(textbox:GetValue())
		end)
		parameterList:AddChild(textbox:GetFrame())
	end
		
	function createInstanceParameterInput(parameter, setParams, parameterList, loadedParam, okButton, okButtonFunction)
		local textbox = LabeledTextInput.new(parameter, parameter, loadedParam or "(none)")
		textbox:SetMouseButton1Function(function()
			isInInstanceSelection = true
			game.Selection:Set({})
			con = game.Selection.SelectionChanged:connect(function()
			local newObj = getSelection()
				if newObj:IsA("GuiObject") then
					textbox:SetValue(newObj.Name)
					setParams[parameter] = newObj
					con:Disconnect()
					con = nil
					isInInstanceSelection = false
				end
			end)
			repeat wait() until con == nil
			return true
		end)
		parameterList:AddChild(textbox:GetFrame())
	end
	
	function createParameterWindow(selectedobj, action, event, parameters, paramList, inputActionContainer)
		local setParams = {}
		local paramLen = getDictionarySize(parameters)
		if canCreateWindow then
			local con
			canCreateWindow = false	
			
			local parameterList = VerticallyScalingListFrame.new("param")
			local paramWindow = CreateDockWidget("paramWindow", (inputActionContainer and inputActionContainer:FindFirstChild("name")) and inputActionContainer.name.Value or action .. " parameters", Enum.InitialDockState.Float, true, true, 400, 200, 400, 200)
			paramWindow:BindToClose(function() 
				if con then con:Disconnect() con = nil end
				isInInstanceSelection = false
				canCreateWindow = true
				paramWindow:Destroy() 
			end)
			
			local bg = GuiUtilities.MakeFrame("background")
			bg.Parent = paramWindow
			bg.Size = UDim2.new(1, 0, 1, 0)
			
			local okButton = CustomTextButton.new("OK", "OK")
			okButton:getButton().Size = UDim2.new(0, 100, 0, 20)
			okButton:getButton().Position = UDim2.new(0.5, -105, 1, -30)
			okButton:getButton().Parent = bg
			
			local okButtonFunction = (function()
				if con then con:Disconnect() con = nil end
				isInInstanceSelection = false
				canCreateWindow = true
				paramWindow:Destroy()
				if paramList then
					local bin = createGuiAction(selectedobj, event, action, setParams)
					createActionButton(selectedobj, action, event, parameters, paramList, bin)
					updateActionFrame(selectedobj, event)
					updateInputFrame(selectedobj)
				else
					updateGuiAction(inputActionContainer, setParams)
					updateActionFrame(selectedobj, event)
					updateInputFrame(selectedobj)
				end
			end)
			
			okButton:getButton().MouseButton1Click:connect(okButtonFunction)
						
			local cancelButton = CustomTextButton.new("Cancel", "Cancel")
			cancelButton:getButton().Size = UDim2.new(0, 100, 0, 20)
			cancelButton:getButton().Position = UDim2.new(0.5, 5, 1, -30)
			cancelButton:getButton().Parent = bg
			cancelButton:getButton().MouseButton1Click:connect(function()
				if con then con:Disconnect() con = nil end
				isInInstanceSelection = false
				canCreateWindow = true
				paramWindow:Destroy()
			end)
			
			local scrollingFrame = AutoScalingScrollingFrame.new("parameters", parameterList._uiListLayout)
			scrollingFrame:GetFrame().Size = UDim2.new(0, 300, 0.8, 0)
			scrollingFrame:GetFrame().Position = UDim2.new(0.5, -150, 0, 10)
			parameterList:GetFrame().Parent = scrollingFrame:GetFrame()
			scrollingFrame:GetFrame().Parent = bg
			
			if inputActionContainer then
				for _, parameter in pairs(inputActionContainer:GetChildren()) do
					if parameter:IsA("ObjectValue") then
						createInstanceParameterInput(parameter.Name, setParams, parameterList, parameter.Value.Name)
						setParams[parameter.Name] = parameter.Value
					elseif parameter:IsA("NumberValue") then
						createNumberParameterInput(parameter.Name, setParams, parameterList, tonumber(parameter.Value))
						setParams[parameter.Name] = tonumber(parameter.Value)
					elseif parameter:IsA("StringValue") then
						createStringParameterInput(parameter.Name, setParams, parameterList, parameter.Value)
						setParams[parameter.Name] = parameter.Value
					end
				end
			else
				for parameter, _type in pairs(parameters) do
					if _type == "instance" then
						createInstanceParameterInput(parameter, setParams, parameterList)			
					elseif _type == "number" then
						createNumberParameterInput(parameter, setParams, parameterList)
						setParams[parameter] =	0
					elseif _type == "string" then
						createStringParameterInput(parameter, setParams, parameterList)
						setParams[parameter] =	""
					end
				end
			end
		end
	end
	
	game.Selection.SelectionChanged:connect(function()
		local obj = getSelection()
		if obj then
			if canCreateWindow and not isInInstanceSelection and obj:IsA("GuiObject") then
				updateInputFrame(obj)			
			end
		else
			clearFrame(InputList:GetFrame())
			clearFrame(ActionList:GetFrame())
			InputSection._frame.TitleBarVisual.TitleLabel.Text = "No element selected!"
			ActionSection._frame.TitleBarVisual.TitleLabel.Text = "No element selected!"
		end
	end)

	BuilderWindow.Click:connect(function()
		DockWidgetPluginGui.Enabled = not DockWidgetPluginGui.Enabled
		clearFrame(InputList:GetFrame())
		clearFrame(ActionList:GetFrame())
	end)
	
	RefreshGuiActions.Click:connect(function()
		local newActions = game.ReplicatedStorage.GuiBuilder.GuiActionInfo:Clone()
		game.ReplicatedStorage.GuiBuilder.GuiActionInfo:Destroy()
		newActions.Parent = game.ReplicatedStorage.GuiBuilder
		GuiActionInfo = require(newActions)
	end)
	
	Settings.Click:connect(function()
		local settings = {
			AutoRequire = true
		}
		
		local func = {
			AutoRequire = function(value)
				if game.StarterPlayer.StarterPlayerScripts:FindFirstChild("GuiBuilderClient") then
					game.StarterPlayer.StarterPlayerScripts.GuiBuilderClient:Destroy()
				end
				if value then
					local ls = script.Parent.GuiBuilderClient:Clone()
					ls.Disabled = false
					ls.Parent = game.StarterPlayer.StarterPlayerScripts
				end
			end
		}
		
		local settingsWindow = CreateDockWidget("settings", "GuiBuilder Settings", Enum.InitialDockState.Float, true, true, 300, 300, 300, 300)
		settingsWindow:BindToClose(function()
			settingsWindow:Destroy()
		end)
		
		local bg = GuiUtilities.MakeFrame("background")
		bg.Parent = settingsWindow
		bg.Size = UDim2.new(1, 0, 1, 0)
		
		local settingsList = VerticallyScalingListFrame.new("settings")
		local settingsFrame = AutoScalingScrollingFrame.new("settings", settingsList._uiListLayout)
		settingsFrame:GetFrame().Parent = bg
		settingsFrame:GetFrame().Size = UDim2.new(1, 0, 1, 0)
		settingsList:GetFrame().Parent = settingsFrame:GetFrame()
		
		for setting, defaultValue in pairs(settings) do
			local element
			if typeof(defaultValue) == "boolean" then
				element = LabeledCheckBox.new(setting, setting, defaultValue, false)
				element:GetFrame().Size = UDim2.new(1, 0, 0, GuiUtilities.kStandardPropertyHeight)
				element:SetValueChangedFunction(function(value)
					func[setting](value)
					plugin:SetSetting(setting, value)
				end)
				settingsList:AddChild(element:GetFrame())
			end
			if plugin:GetSetting(setting) ~= nil then
				element:SetValue(plugin:GetSetting(setting))
			end
		end
	end)
end

main()