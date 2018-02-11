require "actions/action"

---
-- Subclass of STRIPS action Give, specifically for food
-- @param inst Instance to give food
-- @param item food item to give
-- @param player target to give food to
-- @class GiveFood
GiveFood = Class(Give, function(self, inst, item, player)
   Give._ctor(self, inst, item, player)
end)

---
-- Effect of giving food is gave player food
-- @return effect of gave player food as table
function GiveFood:PostEffect()
   return {gave_player_food=true}
end