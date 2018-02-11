require "generalutils/table_ops"
require "generalutils/debugprint"

---
-- Given a list of goals, along with their weighting and urgency,
-- decide which goal to pursue
-- assume that all goals passed in are available goals, otherwise wouldn't be in goal list
-- @param gwulistfn: function that returns list of goals, weighting as a tuple
function selectgoal(gwulistfn)
   
   if gwulistfn then
      local weighted_goals = get_weighted_goals(gwulistfn())
      if weighted_goals then
         local next_goal = max_goal(weighted_goals)
         return next_goal
      end
   end

   return nil
end

---
-- weight the goal values together and return a list of weighted goals as tuple goal, weight
-- this is the just the satisfaction of completing the goal * urgency * weighting (importance)
-- @param gwu_list list of goal, importance weighting tuple
-- @return list of goal, weighting tuples
function get_weighted_goals(gwu_list)

   --  get a weighted goal value, representing how important a goal is, how much it is satisfied and whether its urgent
   local weighted_goals = {}
   if gwu_list == nil or tablesize(gwu_list) < 1 then
      return nil -- not ready yet, this basically should never occur
   end

   local i = 1
   for _, v in pairs(gwu_list) do
      -- v is goal_tuple
      weighted_goals[i] = {}
      weighted_goals[i]["goal"] = v["goal"]

      -- multiply the inverse current satisfaciton value of goal and weightage
      -- we multiply inverse because we usually want to satisfy goals that are less satisfied
      weighted_goals[i]["weighted_value"] = (1 - v.goal:Satisfaction()) * v.weight * v.goal:Urgency()
      info('satisfaction for '..weighted_goals[i]["goal"].name..': '..tostring(v.goal:Satisfaction()))
      info(string.format("%s: %s", weighted_goals[i]["goal"].name, weighted_goals[i]["weighted_value"]))

      i = i + 1
   end

   return weighted_goals
end

---
-- from a list of weighted goals, get the goal with the highest weight
-- this goal is the next to pursue by character
-- @param weighted_goals list of goal,weighting tuple
-- @return goal with highest weighting
function max_goal(weighted_goals)
      
   local max_goal = weighted_goals[1] -- start with first one
   for i = 2, #weighted_goals do
      if weighted_goals[i].weighted_value > max_goal.weighted_value then
         max_goal = weighted_goals[i]
      end
   end

   return max_goal.goal
end
