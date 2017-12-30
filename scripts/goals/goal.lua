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

function Goal:Satisfaction()
   print('Satisfaction() needs to be implemented')
end

function Goal:Urgency()
   return self.urgency
end

function Goal:GetGoalState()
    print('GetGoalState() needs to be implemented')
end
