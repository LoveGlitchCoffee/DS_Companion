------------------------------------------------
-- 
-- Mocks, Stubs
-- 
------------------------------------------------

GoalStub = Class(function (satisfaction, urgency)
   self.satisfaction = satisfaction
   self.urgency = urgency
end)
function GoalStub:Satisfaction()
   return self.satisfaction   
end
function GoalStub:Urgency()
   return self.urgency
end

ActionStub = Class(function (precond, posteff)
   self.precond = precond
   self.posteff = posteff
end)
function ActionStub:Precondition()
   return self.precond
end
function ActionStub:PostEffect()
   return self.posteff
end

------------------------------------------------
-- 
-- Test variable
-- 
------------------------------------------------

goalone = GoalStub(0.5, 0.5)
goalonetuple = {goalone, 0.5}
goaltwo = GoalStub(0.5, 0.5)
goaltwotuple = {goaltwo, 1}

actionone = ActionStub({a=true, b=1}, {c=true})
actiontwo = ActionStub({c=true}, {d=true})
actionseen = ActionStub({seen_a=true}, {d=true})
actionhasweapon = ActionStub({has_weapon=true}, {b=true})