SelectGoal = Class(BehaviourNode, function (self, inst, gwu_list)
		      BehaviourNode._ctor(self, 'SelectGoal')
		      self.inst = inst
		      self.gwu_list = gwu_list -- should be by reference
end)

function SelectGoal:Visit()
   if self.status == READY and self.gwu_list then
      -- Given a list of goals, along with their weighting and urgency
      -- decide which goal to pursue
      -- assume that all goals passed in are available goals, otherwise wouldn't be in goal list
      --------------------------------------
      -- @param goal_weight_urgency_list: list of goals, their weighting and urgency as a 3-tuple
      -- @param next_goal: string describing the next goal agent will fulfill, balanced between urgent, important and satisfaction
      
      local weighted_goals = get_weighted_goals(self.gwu_list)
      local next_goal = max_goal(weighted_goals)
      
      -- return next goal somehow. seems like might have to push event
      print(string.format('my next goal is %s', next_goal))
      self.inst:PushEvent('nextgoalfound', {goal=next_goal})      
   end   
end

function get_weighted_goals( gwu_list )
   --  get a weighted goal value, representing how important a goal is, how much it is satisfied and whether its urgent
   local weighted_goals = {}
   if gwu_list == nil then
      return -- not ready yet
   end

   for i=1,#gwu_list do
      weighted_goals[i] = {}
      weighted_goals[i]['name'] = gwu_list[i]['goal'].name
      -- multiply the inverse current satisfaciton value of goal and weightage
      -- we multiply inverse because we usually want to satisfy goals that are less satisfied
      weighted_goals[i]['weighted_value'] = (1 - gwu_list[i].goal:Satisfaction()) * gwu_list[i].weight * gwu_list[i].goal:Urgency()
      --print (string.format("%s: %s", weighted_goals[i]['name'], weighted_goals[i]['weighted_value']))
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

    return max_goal.name
end
