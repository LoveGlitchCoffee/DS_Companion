require("general-utils/debugprint")

function printt(t)
   if not t then
      return
   end
   for k, v in pairs(t) do
      error(tostring(k) .. ': ' .. tostring(v))
   end
end

function is_subset_key(actionpost, desiredpred)   
   local needseen = false

   for k,v in pairs(desiredpred) do
      if string.find(k, 'seen_') then
         -- the idea is if there is this pred
         -- get rid of it first
         -- a nice heuristic I guess
         needseen = true         
         break
      end
   end

   if needseen then
      error('NEED SEEN')
      -- basically for pred requiring 'seen'
      -- but post has multiple 'seen'
      -- only 1 needs to satisfy
      local seen_one = false      
      local satisfyother = true
      local seenpost = {}
      local post_has_seen = false
      local otherpost = {}

      -- split the posteffects to different groups
      -- because they're treated in different ways
      for k,v in pairs(actionpost) do         
         if string.find( k, 'seen_') then            
            seenpost[k] = v
            post_has_seen = true
         else
            otherpost[k] = v
         end
      end      
            
      if post_has_seen then
         error('LOOKING AT POST SEEN')
         for k,v in pairs(seenpost) do
            error('key '..tostring(k))
            printt(desiredpred)
            if desiredpred[k] then
               seen_one = true
               error('SEEN ONE')
               break
            end
         end
         for k,v in pairs(otherpost) do
            if not desiredpred[k] then
               error('NOT SATISFY OTHER')
               satisfyother = false
               break
            end
         end

         return seen_one and satisfyother
      else
         return false
      end
   else
      error('NORMAL CASE')
      -- handle 'normal' cases
      for k,v in pairs(actionpost) do
         if not desiredpred[k] then
            return false
         end
      end
      
      return true
   end   
end

function is_subset(set, superset)
   local is_subset = true
   for k, v in pairs(set) do
      if superset[k] == nil then
         info('not in world state')
         is_subset = false
         break
      end
      if type(set[k]) == type(superset[k]) then
         if type(set[k]) == 'number'
         and superset[k] < set[k] then
            info('values is more')
            is_subset = false
            break
         end
         -- handle other types
      else
         if superset[k] ~= set[k] then
            error('value not the same')
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