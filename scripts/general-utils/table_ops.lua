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
   print 'checkgini subset'
   local is_subset = true
   for k, v in pairs(set) do
      if superset[k] == nil
      or superset[k] ~= set[k] then
         is_subset = false
         break
      end
   end
   print('reach end')
   return is_subset
end