require "goals/goal"
require "generalutils/config"

---
-- Goal to keep the player fed
-- @param inst Instance to do the feeding
-- @param player player instance
-- @class KeepPlayerFull
KeepPlayerFull = Class(Goal, function(self, inst, player)
   Goal._ctor(self, inst, "KeepPlayerFull", "I'LL FIND YOU SUSTENANCE")
   self.urgency = KEEP_PLAYER_FULL_U_NORMAL

   -- callback to update how urgent this goal is
   self.updateUrgency = function (inst, data)
      local new_percent = data.newpercent
      if new_percent < KEEP_PLAYER_FULL_LOWER then
         -- below certain threshold becomes more urgent
         self.urgency = KEEP_PLAYER_FULL_U_URGENT
      elseif new_percent > KEEP_PLAYER_FULL_UPPER then
         -- reduce urgency once fed enough
         self.urgency = KEEP_PLAYER_FULL_U_NORMAL
      end
   end

   self.player = player
   self.player:ListenForEvent("hungerdelta", self.updateUrgency)
   -- could do for start starving event too
end)

function KeepPlayerFull:OnStop()
   self.player:RemoveEventCallback('hungerdelta', self.updateUrgency)
end

---
-- Current satisfaction for this goal is directly proportionate to
-- how full the player is
-- @return satisfaction for this goal
function KeepPlayerFull:Satisfaction()
   return self.player.components.hunger:GetPercent()
end

---
-- STRIPS precondition to achieving this goal
-- is to have given player food items
-- @return precondition gave_player_food as table
function KeepPlayerFull:GetGoalState()
   return {gave_player_food=true}
end