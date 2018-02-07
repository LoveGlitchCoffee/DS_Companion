require 'actions/action'
require 'behaviours/performsearchfor'
require("general-utils/gameutils")
require("general-utils/config")

SearchFor = Class(Action, function (self, inst, item)
   -- this is for the actual looking
   -- it always assume that search will be successfull
   -- if search is not sucessful, then replan is required
   self.item_to_search = item   
	Action._ctor(self, inst, 'Search for ' .. item, "Sorry, Cannot locate "..item)
end)

function SearchFor:Precondition()
   -- body
   return {}
end

function SearchFor:PostEffect()
   -- body
   local res = {}
   local seenkey = ('seen_' .. self.item_to_search)
   res[seenkey] = true
   return res
end

function SearchFor:GenerateRandomValidPointWithRadius(startpos, minradius, maxradius)
   for i=1,10 do
      local offsetx = math.random( minradius, maxradius)
      local offsetz = math.random( minradius, maxradius)

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

function SearchFor:Cost()
   local currentPos = self.inst:GetPosition()
   self.newPos = self:GenerateRandomValidPointWithRadius(currentPos, MIN_SEARCH_DIST, MAX_SEARCH_DIST)
   if self.newPos then
      return CheckDangerLevel(self.newPos)
   end
   return 0
end

function SearchFor:Perform()
   return PerformSearchFor(self.inst, self.item_to_search, 0.5, self.newPos)
end