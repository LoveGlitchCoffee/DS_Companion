-- what could happen is that we have a behaviour node which basically will be able to pass the instance
-- (agent) into here. so that node may be the decision maker?
StayHealthy = Class(Goal, function(self, inst)
    Goal.init(inst, "StayHealthy")
end)

function StayHealthy:Satisfaction()
    -- body
    -- basically just inverse of hunger percentage

    return self.inst.components.health:GetPercent()
end