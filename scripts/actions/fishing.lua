require 'actions/action'
require "behaviours/performfishing"
require "generalutils/debugprint"
require "generalutils/table_ops"

---
-- STRIPS class for fishing action
-- @param inst Instance to do the fishing
-- @class Fishing
Fishing = Class(Action, function (self, inst)   
   Action._ctor(self, inst, 'Fishing', "NO FISHY")
end)

---
-- Precondition for fishing requires:
-- Has Fishing rod
-- Has inventory space
-- Seen a pond (could be improved with see fishable)
-- @return precondition for fishing
function Fishing:Precondition()
   local seenkey = ('seen_pond') -- very specific atm cuz without expansion, only pond is fishable
   local pred = {}
   pred['has_inv_spc'] = true
   pred[seenkey] = true
   pred['fishingrod'] = 1
   return pred
end

---
-- Effect of fishing succesfully will be seeing a fish
-- @return effect of fishing
function Fishing:PostEffect()   
   -- dun care for value of post effect really
   -- because calculations are done based on world state and precondition
   -- may want to make it real value later based on inventory but not needed   
   local res = {}
   res['seen_fish'] = true
   return res
end

---
-- No preceived cost of fishing
-- Can be improved with CheckDangerLevel()
-- @return preceived cost of fishing
function Fishing:PreceivedCost()
   return 0 -- cost alread count when searching for pond
end

---
-- Perform() of fishing is a custom Fishing Behaviour
-- @return PerformFishing() behaviour
function Fishing:Perform()
   return PerformFishing(self.inst)
end