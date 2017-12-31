require("goals/goal")

KeepPlayerFull = Class(Goal, function(self, inst, player)
   Goal._ctor(self, inst, "KeepPlayerFull")
   self.urgency = 0.2 -- primary task unless extremely important one   

   self.updateUrgency = function (inst, data)
      local new_percent = data.newpercent   
      if new_percent < 0.10 then      
         self.urgency = 0.8      
      elseif new_percent > 0.15 then
         self.urgency = 0.2
      end      
   end
   
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
   return {player_has_food=true}
end