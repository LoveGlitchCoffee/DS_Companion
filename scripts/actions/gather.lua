require 'actions/action'
require 'behaviours/performgather'

FOOD_LIST = {
   'carrot',
   'berries',   
}

Gather = Class(Action, function (self, inst, item)
   self.item = item
   Action._ctor(self, inst, 'Gather ' .. item)
end)

function Gather:Precondition()
   local seenkey = ('seen_' .. self.item)
   local pred = {}
   pred['has_inv_spc'] = true
   pred[seenkey] = true
   return pred
end

function Gather:PostEffect()
   local res = {}
   if FOOD_LIST[self.item] then
      res['have_food'] = true -- change if no longer cares about own hunger
      res[self.item] = 1 -- again don't care about value
   else
      -- dun care for value of post effect really
      -- because calculations are done based on world state and precondition
      -- may want to make it real value later based on inventory but not needed      
      res[self.item] = 1
   end
   return res
end

function Gather:Cost()
   return 2
end

function Gather:Perform()
   return PerformGather(self.inst, self.item)
end