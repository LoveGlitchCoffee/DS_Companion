require 'actions/action'
require 'behaviours/performplacetrap'
require 'general-utils/debugprint'
require 'general-utils/table_ops'

PlaceTrap = Class(Action, function (self, inst, trap)
   Action._ctor(self, inst, 'PlaceTrap ' .. trap)
   self.trap = trap
end)

function PlaceTrap:Precondition()
   local seenkey = ('seen_' .. self.trap)
   local pred = {}
   pred['has_inv_spc'] = true
   pred[seenkey] = true
   return pred
end

function PlaceTrap:PostEffect()   
   -- dun care for value of post effect really
   -- because calculations are done based on world state and precondition
   -- may want to make it real value later based on inventory but not needed   
   local res = {}
   res[self.trap] = 1
   return res
end

function PlaceTrap:Cost()
   return 2
end

function PlaceTrap:Perform()
   return PerformGather(self.inst, self.trap)
end