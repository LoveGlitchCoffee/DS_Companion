Set = {}

function Set.new (t)
   local set = {}
   setmetatable(set, Set.mt)
   for k,v in pairs(t) do
      --print( tostring(k))
      --print( tostring(v))
      set[k] = v
   end
   return set
end

function Set.union (a,b)   
   -- not regular union, also adds value
   local res = {}
   for k, v in pairs(a) do 
      res[k] = v 
   end
   for k, v in pairs(b) do
      if res[k] then
         res[k] = res[k] + v
      else
         res[k] = v
      end      
   end
   return Set.new(res)
end

function Set.complement(a, b)   
   local res = {}
   for k, _ in pairs(a) do
      if b[k] == nil then
         res[k] = a[k]
      end
   end
   return Set.new(res)
end

function Set.printset(t)
   for k, v in pairs(t) do
      print('key ', tostring(k))
      print('value ', tostring(v))
   end
end

Set.mt = {}
Set.mt.__add = Set.union
Set.mt.__sub = Set.complement
Set.mt.__tostring = Set.printset

