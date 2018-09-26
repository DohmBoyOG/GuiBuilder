--[[-------------------------------------GUIBUILDER V 1.0-------------------------------------
	GuiBuilderClientMain should be required by a LocalScript in StarterPlayerScripts for proper functioning 
	
	To create new GuiActions, edit ReplicatedStorage.GuiBuilder.GuiActionInfo. GuiActions have both parameters and an associated function. Click the "Refresh GuiActions" toolbar button to 
	update the plugin's list of GuiActions.
		
	Format:
	
		GuiActionName = { --declaration of a new GuiAction called "GuiActionName"
			StringParam = "string", --a string parameter called "StringParam"
			NumberParam = "number" --a number parameter called "NumberParam"
			InstanceParam = "instance", --an instance parameter called "InstanceParam"
			["func"] = function(args) --the associated function
				
				function argument "args" refers to the list of parameters, e.g.: 
				print(args.StringParam)
				
			end
		},
--]]
