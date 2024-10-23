# -VScript- Multi-thinks
A vscript script which allows an entity to have multiple think functions at once (duh)

Usage:

__MultiThinks.AddMultiThink(entity)__   // Adds the basic think function required for the script to work on the entity

__MultiThinks.RemoveMultiThink(entitiy)__   // Removes it

__MultiThinks.HasMultiThink(entity)__   // Self explanatory

__MultiThinks.AddThink(entity, special_think)__   // Adds the think function to the entity, look below to figure out what special_think is

__MultiThinks.RemoveThink(entity, special_think)__ // Self explanatory

__MultiThinks.RemoveThinkBySlot(entity, slot)__   // ...

__MultiThinks.RemoveThinkByName(entity, name)__   // ...

__MultiThinks.EnableThink(entity, special_think)__   // Enables the think function, does nothing if the entity doesnt have it in the first place

__MultiThinks.DisableThink(entity, special_think__   // Disables the think function, does not remove it, also does nothing if the entity doesnt have it

__MultiThinks.Realign(entity)__   // Look below for an explanation

__MultiThinks.HasThink(entity, special_think)__   // Self explanatory

__MultiThinks.RunLater(entity, function*, an array of arguments, after how much time)__   // Runs a function on an entity with the specified args after X amount of time, this does mean the "self" handle is available to the function\
*An actual function, not the name of a function

__MultiThinks.RunNow(entity)__   // Executes the pending function that "RunLater" made

__MultiThinks.StopRun(entity)__   // Stops the pending function from running (this doesnt work like DisableThink, more like RemoveThink)


__MultiThinks.VThink(think function, name, return value)__ // This is what a special_think is, "think function" is an actual function and not a function name, "name" only exists to be used with RemoveByName.\
And the return value acts the same way as it would with a normal think function, with the difference being that it uses precise values for ticks (ie: a value of -2 would mean the function would run every 2 
ticks, while a value of 2 would mean it would run every 2 seconds)


As for the Realign function, the way this script works is it gives the entity in AddMultiThink a think function called "\_\_multi_think__" (its actually called \_\_default_think__ but only inside of MultiThinks, it
is called \_\_mult_think__ inside of the entity script scope), every time you add a think function, it appends the actual special_think to an array inside of the entity's script scope, then it appends the return
value inside an array, the name inside another array, ... . This is mostly for quicker access of the values, but it might lead to the arrays getting misaligned, so thats what Realign is here for.

Also side note: entity doesnt have to be an entity handle, it can also be a valid entity index if the entity is actually an edict
