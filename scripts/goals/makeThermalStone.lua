require 'goals/goal'

MakeThermalStone = Class(Goal, function(self, inst)
    Goal._ctor(self, inst, "MakeThermalStone")
    self.urgency = 0.1

end)

function MakeThermalStone:Satisfaction()
    return 1 -- just satisfy immediately
end

function MakeThermalStone:GetGoalState()
    return {have=}
end