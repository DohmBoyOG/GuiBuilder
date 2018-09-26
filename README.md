GuiBuilder
=

# Introduction 

GuiBuilder is a Roblox gui development plugin that allows predefined "GuiActions" to be assigned to input events of gui elements.

## Design goals:

- Tie together the Gui programming and design processes 
- Allow for easy creation of new GuiActions
- Allow for robust integration of Roblox's input objects

# The GuiBuilder interface

The GuiBuilder editor menu can be opened with the toolbar button labeled "Editor." Once the editor is open, a desired gui element's input events may be viewed by selecting it. Clicking on an input event in the after selecting an element will display the input's assigned GuiActions:

![image](https://github.com/kennethloeffler/GuiBuilder/blob/master/images/tutorial1.png)

If an event has at least one assigned action, its button in the top frame will be highlighted. The element below doesn't have any assigned actions yet:

![image](https://github.com/kennethloeffler/GuiBuilder/blob/master/images/tutorial3.png)

A new action can be added by clicking on the desired action's "Create" button; this will open the parameter window, where the GuiAction's parameters can be edited. In the following image, a SetBackgroundColor3 action is being assigned to the frame's MouseEnter event:

![image](https://github.com/kennethloeffler/GuiBuilder/blob/master/images/tutorial2.png)

Once a GuiAction has been created, it will be displayed as a button under the appropriate GuiAction label. Created GuiActions can be edited by simply clicking on this button, which will again open the parameter window. 

![image](https://github.com/kennethloeffler/GuiBuilder/blob/master/images/tutorial4.png)

# Requiring the GuiBuilderClientMain.lua module

ReplicatedStorage.GuiBuilder.GuiBuilderClientMain **must** be required by the client for events to be connected. In a LocalScript on the client:

```
require(game.ReplicatedStorage.GuiBuilder.GuiBuilderClientMain)
```

# Creating custom GuiActions

A GuiAction consists of a name, an arbitrary number of parameters, and a function to be called when the GuiAction's associated inout event is fired. GuiActions are defined in ReplicatedStorage.GuiBuilder.GuiActionInfo. The syntax for defining a GuiAction is as follows:

```
GuiActionName = { --declaration of a new GuiAction called "GuiActionName"
  StringParam = "string", --a string parameter called "StringParam"  
  NumberParam = "number" --a number parameter called "NumberParam" 
  InstanceParam = "instance", --an instance parameter called "InstanceParam"  
  ["func"] = function(args) --the associated function  
  end
}
```

A GuiAction necessitating external dependencies can `require()` the needed module within its associated function.
