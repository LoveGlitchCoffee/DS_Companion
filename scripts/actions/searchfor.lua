require "actions/action"
require "behaviours/performsearchfor"
require "generalutils/gameutils"
require "generalutils/config"

---
-- STRIPS action for searching for item
-- @param inst Instance to do the searching
-- @param item item being searched for
-- @class SearchFor
SearchFor = Class(Action, function (self, inst, item)
   self.item_to_search = item
	Action._ctor(self, inst, 'Search for ' .. item, "Sorry, Cannot locate "..item)
end)

---
-- No preconditions to do searching
-- @return empty precondition table
function SearchFor:Precondition()
   return {}
end

---
-- Effect of searching for item, if succesful, is seeing them
-- @return effect of seeing the item as table
function SearchFor:PostEffect()
   local res = {}
   local seenkey = ('seen_' .. self.item_to_search)
   res[seenkey] = true
   return res
end

---
-- Preceived Cost of searching for item at certain random point
-- is the level of danger in that area
-- @return preceived danger in area around search point
-- @see GenerateRandomValidPointWithRadius
-- @see generalutils/gameutils.CheckDangerLevel
function SearchFor:PreceivedCost()

   local currentPos = self.inst:GetPosition()
   self.newPos = GenerateRandomValidPointWithRadius(currentPos, MIN_SEARCH_DIST, MAX_SEARCH_DIST)
   if self.newPos then
      return CheckDangerLevel(self.newPos)
   end

   return 0
end

---
-- Custom Searching behaviour for action.
-- @return PerformSearchFor behaviour with 0.5 interval between checks if found item
-- @see behaviours/performsearchfor.PerformSearchFor
function SearchFor:Perform()
   return PerformSearchFor(self.inst, self.item_to_search, 0.5, self.newPos)
end