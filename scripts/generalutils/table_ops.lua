require "generalutils/debugprint"

---
-- prints out the table in form of key: value
-- @param t the table to print
function printt(t)
   if not t then
      return
   end
   for k, v in pairs(t) do
      error(tostring(k) .. ': ' .. tostring(v))
   end
end

---
-- checks if list has a certain value
-- @param value value to look for
-- @param list the list to look through 
-- @return whether the list has the value
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

---
-- return size of a table
-- @param t table to count size of
-- @return size of the table
function tablesize(t)
   local count = 0
   for k,v in pairs(t) do
      count = count + 1
   end
   return count
end