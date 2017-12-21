require 'actions/action'
require 'behaviours/performgather'
require 'general-utils/debugprint'
require 'general-utils/table_ops'

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
   -- dun care for value of post effect really
   -- because calculations are done based on world state and precondition
   -- may want to make it real value later based on inventory but not needed   
   local res = {}
   res[self.item] = 1
   return res
end

function Gather:Cost()
   return 2
end

function Gather:Perform()
   return PerformGather(self.inst, self.item)
end