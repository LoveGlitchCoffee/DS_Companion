local PlanHolder = Class(function(self, inst)
    self.inst = inst    
    self.currentgoal = nil
    self.actionplan = {}
end)

return PlanHolder