require "actions/action"
require "behaviours/performgather"
require "generalutils/debugprint"
require "generalutils/table_ops"

---
-- STRIPS action for gather items
-- @param inst Instance to gather item
-- @param item item to gather
-- @class Gather
Gather = Class(Action, function (self, inst, item)
   self.item = item
   Action._ctor(self, inst, 'Gather ' .. item, "Sorry, Cannot locate "..item)
end)

---
-- Preconditions to gathering an item
-- Gather item require:
-- 1. Seen the item
-- 2. Has inventory space
-- @return preconditions to gather as a table
function Gather:Precondition()
   local seenkey = ('seen_' .. self.item)
   local pred = {}
   pred['has_inv_spc'] = true
   pred[seenkey] = true
   return pred
end

---
-- Effect of gathering item is having it
-- @return effect of having item as table
function Gather:PostEffect()
   -- don't care for value of post effect really
   -- because calculations are done based on world state and precondition
   -- may want to make it real value later based on inventory but not needed
   local res = {}
   res[self.item] = 1
   return res
end

---
-- No preceived cost for gathering item.
-- Any danger cost is calculated when searching for item.
-- @return Zero cost for gathering
function Gather:PreceivedCost()
   return 0
end

---
-- Custom PerformGather behaviour for action
-- @return PerformGather action for item
-- @see behaviours/performgather.PerformGather
function Gather:Perform()
   return PerformGather(self.inst, self.item)
end