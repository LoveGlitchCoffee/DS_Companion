function select_goal( gwu_list )
    -- Given a list of goals, along with their weighting and urgency
    -- decide which goal to pursue
    -- assume that all goals passed in are available goals, otherwise wouldn't be in goal list
    --------------------------------------
    -- @param goal_weight_urgency_list: list of goals, their weighting and urgency as a 3-tuple
    -- @param next_goal: string describing the next goal agent will fulfill, balanced between urgent, important and satisfaction
        
    weighted_goals = get_weighted_goals(gwu_list)
    next_goal = max_goal(weighted_goals)

    return next_goal
end

function get_weighted_goals( gwu_list )
    --  get a weighted goal value, representing how important a goal is, how much it is satisfied and whether its urgent
    weighted_goals = {}
    for i=1,#gwu_list do        
        weighted_goals[i] = {}
        weighted_goals[i].name = gwu_list[i].goal.name
        -- multiply the inverse current satisfaciton value of goal and weightage
        -- we multiply inverse because we usually want to satisfy goals that are less satisfied
        weighted_goals[i].weighted_value = (1 - gwu_list[i].goal.Satisfaction()) * gwu_list[i].weight * gwu_list[i].urgency
    end

    return weighted_goals
end

function max_goal( weighted_goals )
    -- get the goal with the maximum weighted value
    local max_goal = weighted_goals[1] -- start with first one
    for i=2,#weighted_goals do
        if weighted_goals[i].weighted_value > max_goal.weighted_value
        max_goal = weighted_goals[i]
    end

    return max_goal.name
end