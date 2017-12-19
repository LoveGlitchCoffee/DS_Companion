function GetClosestInstOf(prefab, inst, radius)
   -- body
   local trans = inst.Transform
   local x,y,z = trans:GetWorldPosition()
   local ents = TheSim:FindEntities(x,y,z, radius)
   for k,v in pairs(ents) do
            if v ~= inst and v.prefab == prefab then return v end
         end   
end

function GetClosestInstWithProduct(product, inst ,radius)
   -- body    
   local trans = inst.Transform
   local x,y,z = trans:GetWorldPosition()
   local ents = TheSim:FindEntities(x,y,z, radius)
   for k,v in pairs(ents) do
            if v ~= inst 
            and v.components.pickable
            and v.components.pickable.product == product then return v end
         end   
end