---
-- Abstract base class for all actions
-- Use to represent a possible action in STRIPS
-- @param inst Instance that will perform action
-- @class Action
Action = Class(function (self, inst, name, failreason)
      self.inst = inst
      self.name = name
      self.failreason = failreason
end)

---
-- Preconditions for action
function Action:Precondition()
   print('error. Precondition() of ' .. self.name .. ' needs to be implemented')
end

---
-- Effects of an action
function Action:PostEffect()
   print('error. PostEffect() of ' .. self.name .. ' needs to be implemented')
end

---
-- Preceived cost of an action
function Action:PreceivedCost()
   print('error. Cost() of ' .. self.name .. ' needs to be implemented')
end

---
-- The actual Behaviour of an action in game world
function Action:Perform()
   print('error. Perform() of ' .. self.name .. ' needs to be implemented')
end

---
-- The script used by 'talker' component if action:Perform() fails
function Action:FailReason()
   if self.failreason then
      return self.failreason
   end
   return ""
end

function Action:__eq(b)
   return self.name == b.name -- for now
end

function Action:__tostring()
   return string.format('Action %s', self.name)
end