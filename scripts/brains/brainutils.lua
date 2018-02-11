---
-- returns a table containing a goal object and weight value
-- representing a tuple.
-- @param goal goal object
-- @param weight weighting for the goal
-- @return tuple of goal,weight
function goaltuple( goal, weight)
   local goal_tuple = {goal=goal, weight=weight}
   return goal_tuple
end

---
-- checks if STRIPS effect (of an action) satisfies precondition.
-- This is an OR relationship, if 1 of the post effects
-- satisfies a single precondition, returns true.
-- @param actionpost STRIPS post effect
-- @param desiredpred preconditions to satisfy
-- @return whether any precondition is satisfied
function is_satisfykey(actionpost, desiredpred)
   local satisfysome = false

   for k,v in pairs(actionpost) do
      if desiredpred[k] then
         satisfysome = true
         break
      end
   end

   return satisfysome
end

---
-- Checks if STRIPS condition set is fully satisfied.
-- Used by GOAP planner to check if reached world state (goal) with planning.
-- Caters for number type (allows <=), in addition to other types.
-- AND relation, all must satisfy to return true
-- @param set current state in planning
-- @param superset world state
-- @return whether current planning state satisifes world state
function is_satisfystate(set, superset)
   local is_satisfystate = true

   for k, v in pairs(set) do
      -- catering for default true/false state
      if superset[k] == nil then
         info('not in world state')
         is_satisfystate = false
         break
      end

      if type(set[k]) == type(superset[k]) then
         -- cater for number types, if planning state has <= world state then also passes
         if type(set[k]) == 'number'
         and superset[k] < set[k] then
            info('values is more')
            is_satisfystate = false
            break
         end
      else
         -- handle other types, just same value
         if superset[k] ~= set[k] then
            error('value not the same')
            is_satisfystate = false
            break
         end
      end
   end
   
   return is_satisfystate
end