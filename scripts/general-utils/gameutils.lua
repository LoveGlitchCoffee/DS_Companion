require("general-utils/table_ops")
require("general-utils/debugprint")
require("general-utils/config")

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

function CheckDangerLevel(centrept)
   local dangercounter = 0
   -- if not centrept then
   --    error('not there')
   --    return 0
   -- end
   local ents = TheSim:FindEntities(centrept.x, centrept.y, centrept.z, ASSUME_DANGER_DIST)
   for k, entity in pairs(ents) do
      if entity:HasTag("hostile") or entity:HasTag("scarytoprey") then         
         dangercounter = dangercounter + 3
      elseif entity:HasTag("fire") then
         if entity.prefab ~= "torch" or entity.prefab ~= "fire" then
            dangercounter = dangercounter + 5
         end
      end
   end
   info("danger level: " .. tostring(dangercounter))
   return dangercounter
end
