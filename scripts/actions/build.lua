require 'actions/action'
require("behaviours/performbuild")
require("general-utils/debugprint")
require("general-utils/table_ops")

WEAPONS = {
      'spear'
   }

Build = Class(Action, function (self, inst, item)
   self.item = item
   Action._ctor(self, inst, 'Build ' .. item)   
end)

function Build:Precondition()
   -- body   
   local recipe = GetRecipe(self.item)   
   if not recipe then
      print('ERROR: ' .. self.item .. ' is not buildable')
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
   res[self.item] = 1   
   if has_v(self.item, WEAPONS) then      
      res['has_weapon'] = true
   end
   return res
end

function Build:Cost()
   -- body
   return 0
end

function Build:Perform()
   return PerformBuild(self.inst, self.item)
end