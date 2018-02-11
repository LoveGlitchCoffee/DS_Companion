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
-- Generate random point within the specified radius to go for searching.
-- Checks point is valid before returning.
-- Returns nil if no valid point found after 10 tried. Just class as fail.
-- @param startpos centre of circle
-- @param minradius minimum radius for point to be in from centre
-- @param maxradius maximum radius for point to be in from centre
-- @return vector3 point for search
function SearchFor:GenerateRandomValidPointWithRadius(startpos, minradius, maxradius)
   for i=1,10 do
      local offsetx = math.random( minradius, maxradius)
      local offsetz = math.random( minradius, maxradius)

      -- to randomises if left/right or up/down
      if math.random( 2 ) == 1 then
         offsetx = offsetx * -1
      end
      if math.random(2) == 1 then
         offsetz = offsetz * -1
      end

      local newx = startpos.x + offsetx
      local newz = startpos.z + offsetz
      local tile = GetWorld().Map:GetTileAtPoint(newx, startpos.y, newz)
      if tile ~= GROUND.IMPASSABLE or tile ~= GROUND.INVALID then
         local newpos = Vector3(newx, startpos.y, newz)
         return newpos
      else
         info("not valid ground")
      end
   end
   info("can't find valid ground")
   return nil
end

---
-- Preceived Cost of searching for item at certain random point
-- is the level of danger in that area
-- @return preceived danger in area around search point
-- @see GenerateRandomValidPointWithRadius
-- @see generalutils/gameutils.CheckDangerLevel
function SearchFor:PreceivedCost()

   local currentPos = self.inst:GetPosition()
   self.newPos = self:GenerateRandomValidPointWithRadius(currentPos, MIN_SEARCH_DIST, MAX_SEARCH_DIST)
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