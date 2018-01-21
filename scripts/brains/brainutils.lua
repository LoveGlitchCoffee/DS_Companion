function goaltuple( goal, weight)
   local goal_tuple = {goal=goal, weight=weight}
   --goal_tuple['goal'] = goal
   --goal_tuple['weight'] = weight
   return goal_tuple
end

function is_satisfypred(actionpost, desiredpred)
   local needseen = false
   local needhasweapon = false

   for k,v in pairs(desiredpred) do
      if string.find(k, 'seen_') then
         -- the idea is if there is this pred
         -- get rid of it first
         -- a nice heuristic I guess
         needseen = true
      end
      if string.find(k, 'has_weapon') then
         needhasweapon = true
      end
   end

   if needseen then
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
         for k,v in pairs(seenpost) do
            if desiredpred[k] then
               seen_one = true
               break
            end
         end
         for k,v in pairs(otherpost) do
            if not desiredpred[k] then
               satisfyother = false
               break
            end
         end

         return seen_one and satisfyother
      else
         return false
      end
   elseif needhasweapon then
      -- case need weapon
      -- when build weapon, also build item so need to say can skip that
      for k,v in pairs(actionpost) do
         if k == 'has_weapon' then
            return true
         end
      end
   else
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