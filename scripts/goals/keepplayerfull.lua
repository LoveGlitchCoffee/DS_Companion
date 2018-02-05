require("goals/goal")
require("general-utils/config")

KeepPlayerFull = Class(Goal, function(self, inst, player)
   Goal._ctor(self, inst, "KeepPlayerFull")
   self.urgency = KEEP_PLAYER_FULL_U_NORMAL

   self.updateUrgency = function (inst, data)
      local new_percent = data.newpercent
      if new_percent < KEEP_PLAYER_FULL_LOWER then
         self.urgency = KEEP_PLAYER_FULL_U_URGENT
      elseif new_percent > KEEP_PLAYER_FULL_UPPER then
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

function KeepPlayerFull:Satisfaction()
   return self.player.components.hunger:GetPercent()
end

function KeepPlayerFull:GetGoalState()
   -- design decision
   -- give food generally, which food to give is decided by cost down the line
   -- OR do some sort of calculation here as to which food to give
   -- former is better
   return {gave_player_food=true}
end