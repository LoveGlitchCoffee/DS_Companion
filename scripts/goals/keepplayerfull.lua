require("goals/goal")

KeepPlayerFull = Class(Goal, function(self, inst, player)
   Goal._ctor(self, inst, "KeepPlayerFull")
   self.urgency = 0.3 -- primary task unless extremely important one   
   
   self.updateUrgency = function (inst, data)
      local new_percent = data.newpercent   
      if new_percent < 0.20 then      
         self.urgency = 0.8
      elseif new_percent > 0.15 then
         self.urgency = 0.3
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