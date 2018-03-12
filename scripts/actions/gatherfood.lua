require "actions/action"
require "generalutils/debugprint"
require "generalutils/table_ops"

--- Table containing cost of gathering food
-- usually being time to gather
local FOOD_COST = {
   carrot=1,
   berries=1,
   meat=1,
   froglegs=1,
   fish=1
}

---
-- Subclass of Gather STRIPS action
-- @param inst Instance to gather food
-- @param item food item to gather
-- @class GatherFood
GatherFood = Class(Gather, function (self, inst, item)
   -- this class is special case when need to gather food specifically
   Gather._ctor(self, inst, item)
end)

---
-- Preceived cost of gather food as defined in FOOD_COST table
-- @return preceived cost of gather food
function GatherFood:PreceivedCost()
   return FOOD_COST[self.item]
end