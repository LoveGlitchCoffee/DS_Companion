local SGvanillacharacter = require("stategraphs/SGwilson")

return StateGraph("wilson", SGvanillacharacter.states, SGvanillacharacter.events, "idle", SGvanillacharacter.actionhandlers)