local CollectionService = game:GetService("CollectionService")

local GuiAction = {}
GuiAction.__index = GuiAction

function GuiAction.new(element, event, funcName, parameters)
	local instance = setmetatable({}, GuiAction)
	
	instance._element = element
	instance._event = event
	instance._function = funcName
	instance._parameters = parameters
	
	CollectionService:AddTag(element, "ActionAssignedElement")
	
	local container = Instance.new("Folder")
	container.Name = event .. "," .. funcName
	container.Parent = element
	instance._container = container
	
	for param, v in pairs(parameters) do
		if typeof(v) == "Instance" then
			local objRef = Instance.new("ObjectValue")
			objRef.Name = param
			objRef.Value = v
			objRef.Parent = container
			CollectionService:AddTag(v, "ActionBoundElement")
		elseif typeof(v) == "string" then
			local paramRef = Instance.new("StringValue")
			paramRef.Name = param
			paramRef.Value = v
			paramRef.Parent = container
		elseif typeof(v) == "number" then
			local paramRef = Instance.new("NumberValue")
			paramRef.Name = param
			paramRef.Value = v
			paramRef.Parent = container
		elseif typeof(v) == "boolean" then
			local paramRef = Instance.new("BoolValue")
			paramRef.Name = param
			paramRef.Value = v
			paramRef.Parent = container
		end
	end
	
	return instance, container
end

function GuiAction:ElementIsAssigned(element)
	return CollectionService:HasTag(element, "ActionAssignedElement")
end

function GuiAction:Destroy()
	CollectionService:RemoveTag(self._element, "ActionAssignedElement")
	for i, v in pairs(self._container:GetChildren()) do
		if v.Name == "_elementReference" then
			CollectionService:RemoveTag(v.Value, "ActionBoundElement")
		end
	end
	self._container:Destroy()
end

return GuiAction
