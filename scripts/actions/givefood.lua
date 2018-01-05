require("actions/action")

GiveFood = Class(Give, function(self, inst, item, player)
   Give._ctor(self, inst, item, player)
end)

function GiveFood:PostEffect()
   return {gave_player_food=true}
end