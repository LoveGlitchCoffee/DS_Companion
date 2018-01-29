require 'actions/action'
require 'behaviours/performplacetrap'
require 'general-utils/debugprint'
require 'general-utils/table_ops'

PlaceTrap = Class(Action, function (self, inst, trap)
   Action._ctor(self, inst, 'PlaceTrap ' .. trap)
   self.trap = trap
end)

function PlaceTrap:Precondition()
   local pred = {}
   pred[self.trap] = 1
   return pred
end

function PlaceTrap:PostEffect()   
   -- imaginary
   local post = {}
   
   return post
end

function PlaceTrap:Cost()
   return 0
end

function PlaceTrap:Perform()
   
end