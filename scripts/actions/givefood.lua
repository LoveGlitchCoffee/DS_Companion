require("actions/action")

GiveFood = Class(Give, function(self, inst, item, player)
   Give._ctor(self, inst, item, player)
end)

function GiveFood:Precondition()
   local pred = {}
   --pred[self.item] = 1
   pred['have_food'] = true
   return pred
end

function GiveFood:PostEffect()
   return {gave_player_food=true}
end