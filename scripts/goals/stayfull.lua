require 'goals/goal'
-- what could happen is that we have a behaviour node which basically will be able to pass the instance
-- (agent) into here. so that node may be the decision maker?
StayFull = Class(Goal, function(self, inst)
		    Goal._ctor(self, inst, "StayFull")
		    self.urgency = 0.2 -- start with higher urgency
		    
		    self.updateUrgency = function (inst, data)
		       local new_percent = data.newpercent
		       if new_percent < 0.10 then
			  self.urgency = 0.8
		       elseif new_percent > 0.15 then
			  self.urgency = 0.1
		       end
		    end
		    
		    self.inst:ListenForEvent("hungerdelta", self.updateUrgency)
		    -- could do for start starving event too
end)

function OnStop()
	self.inst:RemoveEventCallback("hungerdelta", self.updateUrgency)
end

function StayFull:Satisfaction()
    -- body
    -- basically just inverse of hunger percentage
   return self.inst.components.hunger:GetPercent()
end

function StayFull:GetGoalState()
	return {eaten=true}
end
