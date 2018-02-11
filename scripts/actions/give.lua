require "actions/action"
require "generalutils/table_ops"
require "behaviours/performgive"

---
-- STRIPS action to give item
-- @param inst Instance to do the giving
-- @param item item to give
-- @param target target to give item to
-- @class Give
Give = Class(Action, function(self, inst, item, target)
   Action._ctor(self, inst, 'Give '..item, "Cannot give "..item)
   self.item = item
   self.target = target -- usually player
end)

---
-- Precondition to giving is having the item
-- @return precondition of having item as table
function Give:Precondition()
   local pred = {}
   pred[self.item] = 1 -- only give 1 instance
   return pred
end

---
-- Effect of giving item is gave item
-- @return effect of gave item as table
function Give:PostEffect()
   local post = {}
   local key = 'gave_'..self.item
   post[key] = true
   return post
end

---
-- No Preceived cost of giving item
-- @return Zero cost of giving item
function Give:PreceivedCost()
   return 0
end

---
-- Custom Give behaviour for giving
-- @return PerformGive behaviour
-- @see behaviours/performgive.PerformGive
function Give:Perform()
   return PerformGive(self.inst, self.item, self.target)
end