local SGperdvanilla = require("stategraphs/SGperd")

local actionhandlers = 
{
   ActionHandler(ACTIONS.GOHOME, "gohome"),
   ActionHandler(ACTIONS.EAT, "eat"),   
   ActionHandler(ACTIONS.PICK, "pick"),
   ActionHandler(ACTIONS.GIVE, "pick"),
   ActionHandler(ACTIONS.PICKUP, "pick")
}

return StateGraph("perdcompanion", SGperdvanilla.states, SGperdvanilla.events, "idle", actionhandlers)