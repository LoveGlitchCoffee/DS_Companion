require("general-utils/debugprint")

Goal = Class(function(self, inst, name)
    -- constructor
    self.inst = inst
    self.name = name
    self.urgency = 0.1
end)

function OnStop()
    error('OnStop() needs to be implemented')
end

function Goal:__tostring()
   return string.format("Goal: %s", self.name)
end

--- Satisfaciton is how much satisfaction currently at
function Goal:Satisfaction()
   error('Satisfaction() needs to be implemented')
end

function Goal:Urgency()
   return self.urgency
end

function Goal:GetGoalState()
    error('GetGoalState() needs to be implemented')
end
