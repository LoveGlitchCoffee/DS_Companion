require "generalutils/table_ops"
require "generalutils/debugprint"
require "generalutils/config"

---
-- Finds the closest entity to a character, within a certain radius,
-- that is of a certain prefab.
-- @param prefab prefab of entity to look for
-- @param inst instance of character to look from, centre of looking radius
-- @param radius radius of search
-- @return the entity instance closests to 'inst' that mathches prefab within 'radius'
function GetClosestInstOf(prefab, inst, radius)
   -- body
   local pt = inst:GetPosition()
   local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, radius)
   for k, entity in pairs(ents) do
      if entity ~= inst and entity.prefab == prefab then
         return entity
      end
   end
   return nil
end

---
-- Finds the closest entity to a character, within a certain radius,
-- that can be harvested for the given product.
-- @param product product being looked for
-- @param inst instance of character to look from, centre of looking radius
-- @param radius radius of search
-- @return the entity instance closests to 'inst' that has 'product', within 'radius'
function GetClosestInstWithProduct(product, inst, radius)
   -- body
   local trans = inst:GetPosition()
   local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, radius)
   for k, entity in pairs(ents) do
      if entity ~= inst and entity.components.pickable and entity.components.pickable.product == product then
         return entity
      end
   end
   return nil
end

---
-- checks and returns the level of danger in a certain area,
-- area is a radius around a centre point
-- @param centrept the centre point
-- @return a value reprensenting the level of danger
function CheckDangerLevel(centrept)

   local dangercounter = 0
   -- if not centrept then
   --    error('not there')
   --    return 0
   -- end

   -- find entities within a radius
   local ents = TheSim:FindEntities(centrept.x, centrept.y, centrept.z, ASSUME_DANGER_DIST)

   for k, entity in pairs(ents) do
      -- if any is hostile then increase danger level
      if entity:HasTag("hostile") or entity:HasTag("scarytoprey") then
         dangercounter = dangercounter + 3
      elseif entity:HasTag("fire") then
         -- if fire in area, increase danger level
         if entity.prefab ~= "torch" or entity.prefab ~= "fire" then
            dangercounter = dangercounter + 5
         end
      end
   end
   info("danger level: " .. tostring(dangercounter))
   return dangercounter
end
