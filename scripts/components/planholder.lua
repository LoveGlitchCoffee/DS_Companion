local PlanHolder = Class(function(self, inst)
    self.inst = inst
    self.currentgoal = nil
    self.actionplan = {}
end)

function PlanHolder:OnLoad(data, newents)
   -- empty for now
end

function PlanHolder:OnSave()
   -- empty for now
end

function PlanHolder:OnUpdate(dt)
   -- empty for now
end

function PlanHolder:GenerateActionSequence()    
    for a=1,#self.actionplan do
        table.insert(res, #res+1, self.actionplan[a].Perform())
    end
end

return PlanHolder