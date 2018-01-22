require("general-utils/debugprint")

function printt(t)
   if not t then
      return
   end
   for k, v in pairs(t) do
      error(tostring(k) .. ': ' .. tostring(v))
   end
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

function tablesize(t)
   local count = 0
   for k,v in pairs(t) do
      count = count + 1
   end
   return count
end