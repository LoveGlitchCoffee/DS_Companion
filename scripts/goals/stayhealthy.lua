require 'goals/goal'
-- what could happen is that we have a behaviour node which basically will be able to pass the instance
-- (agent) into here. so that node may be the decision maker?
StayHealthy = Class(Goal, function(self, inst)
		       Goal._ctor(self, inst, "StayHealthy")

		       self.updateUrgency = function (inst, data)
		       local new_percent = data.newpercent
		       if new_percent < 0.15 then
			  self.urgency = 0.8
		       elseif new_percent > 0.15 then
			  self.urgency = 0.1
		       end
		    end
end)

function StayHealthy:Satisfaction()
   return self.inst.components.health:GetPercent()
end
