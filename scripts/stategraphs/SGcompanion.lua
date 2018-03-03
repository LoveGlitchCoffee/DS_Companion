local SGvanillacharacter = require("stategraphs/SGwilson")

return StateGraph("companion", SGvanillacharacter.states, SGvanillacharacter.events, "idle", SGvanillacharacter.actionhandlers)