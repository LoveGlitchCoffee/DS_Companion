------------------------------------------------
-- 
-- Mocks, Stubs
-- 
------------------------------------------------

GoalStub = Class(function (self, satisfaction, urgency)
   self.satisfaction = satisfaction
   self.urgency = urgency
end)
function GoalStub:Satisfaction()
   return self.satisfaction   
end
function GoalStub:Urgency()
   return self.urgency
end

ActionStub = Class(function (self, precond, posteff)
   self.precond = precond
   self.posteff = posteff
end)
function ActionStub:Precondition()
   return self.precond
end
function ActionStub:PostEffect()
   return self.posteff
end


TransformStub = Class(function(self, x, y, z)
   self.x = x
   self.y = y
   self.z = z
end)
function TransformStub:GetWorldPosition()
   return self.x, self.y, self.z
end

InstStub = Class(function (self, trans)
   self.Transform = trans
end)


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

inst = InstStub(TransformStub(0, 0, 0))
player = InstStub(TransformStub(10, 10, 0))