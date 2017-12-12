require 'actions/action'

SearchFor = Class(Action, function (self, inst, item)   
   -- this is for the actual looking
   -- it always assume that search will be successfull
   -- if search is not sucessful, then replan is required
	self.item_to_search = item
	Action._ctor(self, inst, 'Search for ' .. item)
end)

function SearchFor:Precondition()
   -- body
   return {}
end

function SearchFor:PostEffect()
   -- body
   local res = {}
   res['found'] = self.item_to_search
   return res
end

function SearchFor:Cost()
   -- body
   return 5
end