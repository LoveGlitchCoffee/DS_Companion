require("general-utils/table_ops")
require("general-utils/debugprint")

function selectgoal(gwulistfn)
   -- Given a list of goals, along with their weighting and urgency
   -- decide which goal to pursue
   -- assume that all goals passed in are available goals, otherwise wouldn't be in goal list
   --------------------------------------
   -- @param goal_weight_urgency_list: list of goals, their weighting and urgency as a 3-tuple
   -- @param next_goal: string describing the next goal agent will fulfill, balanced between urgent, important and satisfaction
    if gwulistfn then
       local weighted_goals = get_weighted_goals(gwulistfn())
       if weighted_goals then
          local next_goal = max_goal(weighted_goals)
          return next_goal
       end
    end

    return nil
end

function get_weighted_goals( gwu_list )
   --  get a weighted goal value, representing how important a goal is, how much it is satisfied and whether its urgent
   local weighted_goals = {}
   if gwu_list == nil or #gwu_list < 1 then
      return nil -- not ready yet, this basically should never occur
   end

   local i = 1
   for _, v in pairs(gwu_list) do
      -- v is goal_tuple
      weighted_goals[i] = {}
      weighted_goals[i]['goal'] = v['goal']

      -- multiply the inverse current satisfaciton value of goal and weightage
      -- we multiply inverse because we usually want to satisfy goals that are less satisfied
      weighted_goals[i]['weighted_value'] = (1 - v.goal:Satisfaction()) * v.weight * v.goal:Urgency()
      info(string.format("%s: %s", weighted_goals[i]['goal'].name, weighted_goals[i]['weighted_value']))

      i = i + 1
   end

   return weighted_goals
end

function max_goal( weighted_goals )
    -- get the goal with the maximum weighted value
    local max_goal = weighted_goals[1] -- start with first one
    for i=2,#weighted_goals do
       if weighted_goals[i].weighted_value > max_goal.weighted_value
       then
          max_goal = weighted_goals[i]
       end
    end

    return max_goal.goal
end
