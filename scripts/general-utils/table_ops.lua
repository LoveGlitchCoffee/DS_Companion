function printt(t)
   for k, v in pairs(t) do
      print(tostring(k) .. ': ' .. tostring(v))
   end
end

function is_subset_key(set, superset)
   -- Checks if a table is a subset of another
   -- Only accounting for keys, not values   
   local is_subset = true
   for k, _ in pairs(set) do
      if superset[k] == nil then   
         is_subset = false
         break
      end      
   end   
   return is_subset
end

function is_subset(set, superset)   
   local is_subset = true
   for k, v in pairs(set) do
      if superset[k] == nil then
         is_subset = false
         break
      end
      if type(set[k]) == type(superset[k]) then
         if type(set[k]) == 'number' 
         and superset[k] < set[k] then
            is_subset = false
            break         
         end
         -- handle other types
      else
         if superset[k] ~= set[k] then
            is_subset = false
            break
         end
      end         
   end
   return is_subset
end

function has_v(value, list)
   local found = false
   for i,v in ipairs(list) do      
      if v == value then
         found = true         
         break
      end
   end   
   return found
end 