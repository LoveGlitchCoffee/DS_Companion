require 'general-utils/debugprint'
require 'behaviours/performsearchfor'

PerformSearchForResource = Class(PerformSearchFor, function(self, inst, entity)
   -- search for is travelling in a random direction
   -- then do another check to see if entity wanted is in view
   -- fail if no entity is in view then
   PerformSearchFor._ctor(self, inst, entity)   
end)

function PerformSearchForResource:CheckTarget()
   return FindEntity(self.inst, 4, function(resource)
      if resource.components.pickable then -- might want to change at some point
         return resource.components.pickable.product == self.entity
      else
         return resource.prefab == self.entity
      end
   end)
end
