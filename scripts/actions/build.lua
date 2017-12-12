require 'actions/action'

Build = Class(Action, function (self, inst, item)
		  self.item_to_build = item
		  Action._ctor(self, inst, 'Build ' .. item)
end)

function Build:Precondition()
   -- body
   print ('getting recipe for ' .. self.item_to_build)
   local recipe = GetRecipe(self.item_to_build)   
   if not recipe then
      print('ERROR: ' .. self.item_to_build .. ' is not buildable')
      return nil
   end   
   local precond = {} -- convert to my own 'logic'   
   for _,ingredient in ipairs(recipe.ingredients) do
      precond[ingredient.type] = ingredient.amount
   end   
   return precond
end

function Build:PostEffect()
   -- body   
   local res = {}
   res[self.item_to_build] = 1
   return res
end

function Build:Cost()
   -- body
   return 2
end