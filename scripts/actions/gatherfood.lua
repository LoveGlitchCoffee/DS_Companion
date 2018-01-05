require 'actions/action'
require 'general-utils/debugprint'
require 'general-utils/table_ops'

local FOOD_COST = {
   carrot=1,
   berries=1
}

GatherFood = Class(Gather, function (self, inst, item)   
   -- this class is special case when need to gather food specifically
   Gather._ctor(self, inst, item)
end)

function GatherFood:Cost()
   return FOOD_COST[self.item]
end