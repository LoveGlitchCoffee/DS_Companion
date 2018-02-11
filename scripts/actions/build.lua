require 'actions/action'
require "behaviours/performbuild"
require "generalutils/debugprint"
require "generalutils/table_ops"

--- table containing all prefabs considered weapons
WEAPONS = {
      'spear'
   }

---
-- STRIPS action for crafting item in game
-- @param inst Instance to do the crafting
-- @param item Item to craft
-- @class Build
Build = Class(Action, function (self, inst, item)
   self.item = item
   Action._ctor(self, inst, 'Build ' .. item, "ERROR IN CRAFTING")
end)

---
-- Precondition for crafting is having all ingredients
-- @return ingredients as precondition table
function Build:Precondition()
   local recipe = GetRecipe(self.item)
   if not recipe then
      error('ERROR: ' .. self.item .. ' is not buildable')
      return nil
   end

   local precond = {} -- convert to my own 'precondition format'
   for _,ingredient in ipairs(recipe.ingredients) do
      precond[ingredient.type] = ingredient.amount
   end

   return precond
end

---
-- Effect of crafting gives item to companion
-- If item is in WEAPONS table then effect 'has_weapon also added'
-- @return effect of crafting
function Build:PostEffect()
   local res = {}
   res[self.item] = 1
   if has_v(self.item, WEAPONS) then
      res['has_weapon'] = true
   end
   return res
end

---
-- Crafting item have no preceived cost
-- @return cost of crafting
function Build:PreceivedCost()
   return 0
end

---
-- Perform of build is custom build behaviour.
-- default build behaviour is too coupled with Player
-- @return PerformBuild Behaviour for specified item
function Build:Perform()
   return PerformBuild(self.inst, self.item)
end