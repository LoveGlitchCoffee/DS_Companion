require 'actions/searchfor'
require 'behaviours/performsearchforresource'

SearchForResource = Class(SearchFor, function (self, inst, item)   
   -- this is for the actual looking
   -- it always assume that search will be successfull
   -- if search is not sucessful, then replan is required	
	SearchFor._ctor(self, inst, item)
end)


function SearchForResource:Perform()
   return PerformSearchForResource(self.inst, self.item_to_search)
end