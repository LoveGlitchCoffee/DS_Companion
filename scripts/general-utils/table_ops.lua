function is_subset(set, superset)
   local is_subset = true   
   for k, _ in pairs(set) do
      if superset[k] == nil then
	 is_subset = false
	 break
      end
   end
   return is_subset
end

function printt(t)
   for k, v in pairs(t) do
      print(tostring(k) .. ': ' .. tostring(v))      
   end
end