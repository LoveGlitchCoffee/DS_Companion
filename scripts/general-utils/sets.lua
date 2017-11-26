Set = {}

function Set.new (t)
   local set = {}
   setmetatable(set, Set.mt)
   for _, l in ipairs(t) do set[l] = true end
   return set
end

function Set.union (a,b)
   print 'adding set'
   local res = {}
   for k in pairs(a) do res[k] = true end
   for k in pairs(b) do res[k] = true end
   return res
end

function Set.complement(a, b)
   print 'subtracting set'
   local res = {}
   for k in pairs(a) do
      if b[k] == nil then
	 res[k] = a[k]
      end
   end
   return res
end

Set.mt = {}
Set.mt.__add = Set.union
Set.mt.__sub = Set.complement
