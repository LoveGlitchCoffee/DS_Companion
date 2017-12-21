require 'actions/action'
require 'general-utils/debugprint'
require 'general-utils/table_ops'

local FOOD_LIST = {
   'carrot',
   'berries'
}

GatherFood = Class(Gather, function (self, inst, item)   
   -- this class is special case when need to gather food specifically
   Gather._ctor(self, inst, item)
end)

function GatherFood:PostEffect()
   return {have_food=true}
end