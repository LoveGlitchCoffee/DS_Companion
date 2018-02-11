require "actions/searchfor"
require "behaviours/performsearchforresource"

---
-- Subclass of SearchFor STRIPS action.
-- Difference is that resource are product of certain items, so harvested rather than picked up
-- @param inst Instance to search for resource
-- @param item resource item to search for
-- @class SearchForResource
SearchForResource = Class(SearchFor, function (self, inst, item)
   SearchFor._ctor(self, inst, item)
   self.name = "Search For Resource "..item
end)

---
-- Custom SearchForResource behaviour
-- @return PerformSearchForResource behaviour with 0.5 interval between checks if found resource
function SearchForResource:Perform()
   return PerformSearchForResource(self.inst, self.item_to_search, 0.5, self.newPos)
end