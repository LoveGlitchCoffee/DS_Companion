require 'actions/action'
require("behaviours/performfishing")
require("general-utils/debugprint")
require("general-utils/table_ops")

Fishing = Class(Action, function (self, inst)   
   Action._ctor(self, inst, 'Fishing')
end)

function Fishing:Precondition()
   local seenkey = ('seen_pond') -- very specific atm cuz without expansion, only pond is fishable
   local pred = {}
   pred['has_inv_spc'] = true
   pred[seenkey] = true
   pred['fishingrod'] = 1
   return pred
end

function Fishing:PostEffect()   
   -- dun care for value of post effect really
   -- because calculations are done based on world state and precondition
   -- may want to make it real value later based on inventory but not needed   
   local res = {}
   res['seen_fish'] = true
   return res
end

function Fishing:Cost()
   return 0 -- cost alread count when searching for pond
end

function Fishing:Perform()
   return PerformFishing(self.inst)
end