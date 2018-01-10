require("stategraphs/c")

local SGvanillacharacter = require("stategraphs/SGwilson")

CommonStates.AddWalkStates(states,
{

}
, )

return StateGraph("companion", SGvanillacharacter.states, SGvanillacharacter.events, "idle", SGvanillacharacter.actionhandlers)