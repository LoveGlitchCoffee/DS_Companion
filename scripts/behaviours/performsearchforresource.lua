require "generalutils/debugprint"
require "behaviours/performsearchfor"
require "generalutils/config"

---
-- Subclass of PerformSearchFor behaviour, way of checking for item is different,
-- specific to resource that can be harvested
-- @param inst Instance to do the searching
-- @param resource resource to harvest
-- @class PerformSearchForResource
-- @see behaviours/performsearchfor.PerformSearchFor
PerformSearchForResource = Class(PerformSearchFor, function(self, inst, resource, period, newpos)
   PerformSearchFor._ctor(self, inst, resource, period, newpos)
end)

---
-- Checking method checks for product of pickable
-- @return instant of reseource
function PerformSearchForResource:CheckTarget()
   return FindEntity(self.inst, SIGHT_DISTANCE, function(resource)
      if resource.components.pickable then -- might want to change at some point
         return resource.components.pickable.product == self.resource
      else
         return resource.prefab == self.resource
      end
   end)
end
