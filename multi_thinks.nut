//If you want to credit me for this script, sure (https://steamcommunity.com/id/Mr_Croissant/). If you dont want to, why not lol
//Just dont credit someone else for it, its either me or no one :) .

if (!("__V_MULTI_THINKS_SCRIPT__" in getroottable()))
{
getroottable()["__V_MULTI_THINKS_SCRIPT__"] <- true;

local Find = function (arr, elem) {
    return typeof(arr.find(elem)) == "integer"
};

local VMultiThinks = class {
    MAX_ENT_THINKS = 16;
    MAX_TICK_THINKS = 1026432000;
    //TODO: possibly replace the tick system RunLater is using with the
    //same one that is used by __default_think__

    __default_think__ = function () {
        local scope = self.GetScriptScope();
        local ent_scope = scope.__advanced_think_functions_multi_thinks__;
        local func_array = ent_scope.__think_functions;
        local func_array_base_delays = ent_scope.__think_functions_delays;
        local func_array_delays = ent_scope.__think_functions_next_activation_delays;
        local func_array_active = ent_scope.__think_functions_active;
        local func_array_len = ent_scope.__think_functions_array_len;
        local tick = ent_scope.__think_tick;
        local late_func = ent_scope.__think_later;
        local late_tick = ent_scope.__think_later_ticks;
        local late_args = ent_scope.__think_later_args;
        for (local i=0; i < func_array_len; i++) {
            local active = func_array_active[i];
            if (!active)
                continue;
            local base_delay = func_array_base_delays[i];
            local delay = func_array_delays[i];
            local func = func_array[i];
            delay--;
            if (delay <= 0)
            {
                func.call({self=self});
                delay = base_delay;
            };
        };
        if (late_func && late_tick == tick) {
            late_func.acall([{self=self}].extend(late_args));
            MultiThinks.StopRun(self);
        };
        ent_scope.__think_tick++;
        if (ent_scope.__think_tick > MultiThinks.MAX_TICK_THINKS)
            ent_scope.__think_tick = 0;
        return -1;
    };
    
    AddMultiThink = function (ent) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local ent_scope = ent.GetScriptScope();
        if (!ent_scope) {
            ent.ValidateScriptScope();
            ent_scope = ent.GetScriptScope();
        };
    
        if (!("__advanced_think_functions_multi_thinks__" in ent_scope))
        {
            ent_scope.__multi_think__ <- __default_think__;
            ent_scope.__advanced_think_functions_multi_thinks__ <- {
                __think_functions = [],
                __think_functions_names = [],
                __think_functions_vthinks = [],
                __think_functions_delays = [],
                __think_functions_next_activation_delays = [],
                __think_functions_active = [],
                __think_later_args = [],
                __think_tick = 0,
                __think_later_ticks = 0,
                __think_functions_array_len = 0,
                __think_later = null,
                __think_tick_rate = GetTickRate(),
                __think_tick_len = GetTickLength(),
            };
        }
        else
            return false;
    
        AddThinkToEnt(ent, "__multi_think__");
        return true;
    };
    RemoveMultiThink = function (ent) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local ent_scope = ent.GetScriptScope();
        StopRun(ent);
        delete ent_scope.__advanced_think_functions_multi_thinks__;
        AddThinkToEnt(ent, "");
        AddThinkToEnt(ent, null);
    };
    HasMultiThink = function (ent) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local ent_scope = ent.GetScriptScope();
        return "__advanced_think_functions_multi_thinks__" in ent_scope;
    };
    
    AddThink = function (ent, think) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local scope = ent.GetScriptScope();
        local ent_scope = scope.__advanced_think_functions_multi_thinks__;
        local func_array = ent_scope.__think_functions_vthinks;
        if (!Find(func_array, think) && func_array.len() <= MAX_ENT_THINKS) {
            ent_scope.__think_functions_vthinks.append(think);
            ent_scope.__think_functions.append(think.GetThink());
            ent_scope.__think_functions_names.append(think.GetThinkName());
            ent_scope.__think_functions_active.append(think.IsActive());
            local _time = think.GetTime();
            if (_time <= 0)
                _time = abs(_time);
            else
                _time *= ent_scope.__think_tick_rate;
            ent_scope.__think_functions_delays.append(_time);
            ent_scope.__think_functions_next_activation_delays.append(_time);
            ent_scope.__think_functions_array_len++;
            return true;
        };
        if (func_array.len() > MAX_ENT_THINKS) {
            printl("\nERROR: MAX THINK FUNCTIONS ON AN ENTITY REACHED: CURRENT MAXIMUM IS " + MAX_ENT_THINKS + "\n");
            return false;
        };
    };
    RemoveThink = function (ent, think) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local scope = ent.GetScriptScope();
        local ent_scope = scope.__advanced_think_functions_multi_thinks__;
        local func_array = ent_scope.__think_functions_vthinks;
        try {
            local slot = func_array.find(think);
            ent_scope.__think_functions_vthinks.remove(slot);
            ent_scope.__think_functions.remove(slot);
            ent_scope.__think_functions_names.remove(slot);
            ent_scope.__think_functions_delays.remove(slot);
            ent_scope.__think_functions_next_activation_delays.remove(slot);
            ent_scope.__think_functions_active.remove(slot);
            ent_scope.__think_functions_array_len--;
        }
        catch (_error) {
            if (Find(func_array, think)) {
                printl("Error: Missaligned arrays")
            };
            return false;
        };
        return true;
    };
    RemoveThinkBySlot = function (ent, slot) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local scope = ent.GetScriptScope();
        local ent_scope = scope.__advanced_think_functions_multi_thinks__;
        try {
            ent_scope.__think_functions_vthinks.remove(slot);
            ent_scope.__think_functions.remove(slot);
            ent_scope.__think_functions_names.remove(slot);
            ent_scope.__think_functions_delays.remove(slot);
            ent_scope.__think_functions_next_activation_delays.remove(slot);
            ent_scope.__think_functions_active.remove(slot);
            ent_scope.__think_functions_array_len--;
        }
        catch (_error) {
            printl("Error: Slot does not contain a think function");
            return false;
        };
        return true;
    };
    RemoveThinkByName = function (ent, name) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local scope = ent.GetScriptScope();
        local ent_scope = scope.__advanced_think_functions_multi_thinks__;
        local slot = ent_scope.__think_functions_names.find(name);
        try {
            ent_scope.__think_functions_vthinks.remove(slot);
            ent_scope.__think_functions.remove(slot);
            ent_scope.__think_functions_names.remove(slot);
            ent_scope.__think_functions_delays.remove(slot);
            ent_scope.__think_functions_next_activation_delays.remove(slot);
            ent_scope.__think_functions_active.remove(slot);
            ent_scope.__think_functions_array_len--;
        }
        catch (_error) {
            printl("Error: Name of think function not found inside of the entity");
            return false;
        };
        return true;
    };

    EnableThink = function (ent, think) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local scope = ent.GetScriptScope();
        local ent_scope = scope.__advanced_think_functions_multi_thinks__;
        local func_array = ent_scope.__think_functions_vthinks;
        if (Find(func_array, think)) {
            think.Enable();
            local slot = func_array.find(think);
            ent_scope.__think_functions_active[slot] = true;
            return true;
        }
        else {
            return false;
        };
    };
    DisableThink = function (ent, think) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local scope = ent.GetScriptScope();
        local ent_scope = scope.__advanced_think_functions_multi_thinks__;
        local func_array = ent_scope.__think_functions_vthinks;
        if (Find(func_array, think)) {
            local slot = func_array.find(think);
            ent_scope.__think_functions_active[slot] = false;
            think.Disable();
            return true;
        }
        else {
            return false;;
        };
    };

    Realign = function (ent) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local scope = ent.GetScriptScope();
        local ent_scope = scope.__advanced_think_functions_multi_thinks__;
        for (local i=0; i < ent_scope.__think_functions_array_len; i++) {
            local think = ent_scope.__think_functions_vthinks[i];
            ent_scope.__think_functions[i] = think.GetThink();
            ent_scope.__think_functions_names[i] = think.GetThinkName();
            ent_scope.__think_functions_delays[i] = think.GetTime();
            ent_scope.__think_functions_next_activation_delays[i] = think.GetTime();
            ent_scope.__think_functions_active[i] = think.IsActive();
        };
    };

    HasThink = function (ent, think) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local scope = ent.GetScriptScope();
        local ent_scope = scope.__advanced_think_functions_multi_thinks__;
        local func_array = ent_scope.__think_functions_vthinks;
        return Find(func_array, think);
    };

    RunLater = function (ent, func, args, delay) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local scope = ent.GetScriptScope();
        local ent_scope = scope.__advanced_think_functions_multi_thinks__;
        local tickrate = ent_scope.__think_tick_rate;
        ent_scope.__think_later = func;
        ent_scope.__think_later_args = args;
        if (delay < 0)
            ent_scope.__think_later_ticks = ent_scope.__think_tick - delay;
        else
            ent_scope.__think_later_ticks = ent_scope.__think_tick + delay*tickrate;
        return true;
    };
    RunNow = function (ent) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local scope = ent.GetScriptScope();
        local ent_scope = scope.__advanced_think_functions_multi_thinks__;
        if (ent_scope.__think_later)
            ent_scope.__think_later.acall([{self=ent}].extend(ent_scope.__think_later_args));
        StopRun(ent);
        return true;
    };
    StopRun = function (ent) {
        if (typeof(ent) == "integer")
            ent = EntIndexToHScript(ent);
        local scope = ent.GetScriptScope();
        local ent_scope = scope.__advanced_think_functions_multi_thinks__;
        ent_scope.__think_later = null;
        ent_scope.__think_later_ticks = 0;
        ent_scope.__think_later_args = [];
        return true;
    };
    GetTickRate = function () {
        return (1/FrameTime()).tointeger();
    };
    GetTickLength = function () {
        return FrameTime();
    };
};

local VMultiThinksEx = class extends VMultiThinks {
    VThink = class {
        think_func = null;
        think_name = "";
        delay = 0;
        is_active = false;
        constructor (think, name, time) {
            think_func = think;
            think_name = name;
            is_active = true;
            delay = time;
        };
        function SetThink(think, name, time, active) {
            think_func = think;
            think_name = name;
            is_active = active;
            delay = time;
            return;
        };
        function GetThinkName() {
            return think_name;
        };
        function GetThink() {
            return think_func;
        };
        function IsActive() {
            return is_active;
        };
        function GetTime() {
            return delay;
        };
        function Enable() {
            is_active = true;
        };
        function Disable() {
            is_active = false;
        };
    };
};

::MultiThinks <- VMultiThinksEx();
};

/*
A vscript script which allows an entity to have multiple think functions at once (duh)

Usage:

MultiThinks.AddMultiThink(entity) // Adds the basic think function required for the script to work on the entity

MultiThinks.RemoveMultiThink(entitiy) // Removes it

MultiThinks.HasMultiThink(entity) // Self explanatory

MultiThinks.AddThink(entity, special_think) // Adds the think function to the entity, look below to figure out what special_think is

MultiThinks.RemoveThink(entity, special_think) // Self explanatory

MultiThinks.RemoveThinkBySlot(entity, slot) // ...

MultiThinks.RemoveThinkByName(entity, name) // ...

MultiThinks.EnableThink(entity, special_think) // Enables the think function, does nothing if the entity doesnt have it in the first place

MultiThinks.DisableThink(entity, special_think // Disables the think function, does not remove it, also does nothing if the entity doesnt have it

MultiThinks.Realign(entity) // Look below for an explanation

MultiThinks.HasThink(entity, special_think) // Self explanatory

MultiThinks.RunLater(entity, function*, an array of arguments, after how much time) // Runs a function on an entity with the specified args after X amount of time, this does mean the "self" handle is available to the function
*An actual function, not the name of a function

MultiThinks.RunNow(entity) // Executes the pending function that "RunLater" made

MultiThinks.StopRun(entity) // Stops the pending function from running (this doesnt work like DisableThink, more like RemoveThink)

MultiThinks.VThink(think function, name, return value) // This is what a special_think is, "think function" is an actual function and not a function name, "name" only exists to be used with RemoveByName.
And the return value acts the same way as it would with a normal think function, with the difference being that it uses precise values for ticks (ie: a value of -2 would mean the function would run every 2 ticks, while a value of 2 would mean it would run every 2 seconds)

As for the Realign function, the way this script works is it gives the entity in AddMultiThink a think function called "__multi_think__" (its actually called __default_think__ but only inside of MultiThinks, it is called __mult_think__ inside of the entity script scope), every time you add a think function, it appends the actual special_think to an array inside of the entity's script scope, then it appends the return value inside an array, the name inside another array, ... . This is mostly for quicker access of the values, but it might lead to the arrays getting misaligned, so thats what Realign is here for.

Also side note: entity doesnt have to be an entity handle, it can also be a valid entity index if the entity is actually an edict
*/
