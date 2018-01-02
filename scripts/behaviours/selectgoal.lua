require("general-utils/table_ops")
require("general-utils/debugprint")
require("actions")

SelectGoal = Class(function (self, inst, gwulistfn)
   BehaviourNode._ctor(self, 'SelectGoal')
   self.inst = inst   
   self.gwulistfn = gwulistfn

   self.selectgoalaction = Action()
   self.selectgoalaction.fn = function(act)
      print('SELECTING GOAL ACTION')
      act.doer:PushEvent('nextgoalfound', {goal=self.next_goal})
      return true
   end   
end)

function SelectGoal:OnFail()   
   error('FAILED')
   self.pendingstatus = FAILED
end
function SelectGoal:OnSucceed()   
   error('SUCCEED')
   self.pendingstatus = SUCCESS
end

function SelectGoal:Visit()
   if self.status == READY then

      if self.gwulistfn  then
         local weighted_goals = get_weighted_goals(self.gwulistfn())               
         --if not weighted_goals then
         --    self.status = FAILED
         --    return
         --end
         self.next_goal = max_goal(weighted_goals)
         --if not next_goal then
         --    self.status = FAILED
         --    return
         --end      
         -- Given a list of goals, along with their weighting and urgency
         -- decide which goal to pursue
         -- assume that all goals passed in are available goals, otherwise wouldn't be in goal list
         --------------------------------------
         -- @param goal_weight_urgency_list: list of goals, their weighting and urgency as a 3-tuple
         -- @param next_goal: string describing the next goal agent will fulfill, balanced between urgent, important and satisfaction      
                           
         --local pAction = BufferedAction(self.inst, nil, ACTIONS.WALKTO)
         --pAction:AddFailAction(function() self:OnFail() end)
         --pAction:AddSuccessAction(function() self:OnSucceed() end)
         --self.action = pAction
         --self.pendingstatus = nil
         --self.inst.components.locomotor:PushAction(pAction, true)
         error('SELECTED GOAL')
         self.inst:PushEvent('nextgoalfound', {goal=self.next_goal})
         self.start = SUCCESS
         --self.status = RUNNING
      else
        --self.status = FAILED
      end
   --elseif self.status == RUNNING then
   --   if self.pendingstatus then
   --      self.status = self.pendingstatus
   --      warning('\nkeep running\n')
   --   elseif not self.action:IsValid() then
   --      warning('\nfail as action not valid\n')
   --      self.status = FAILED
   --   end
   --end
   end
end

function get_weighted_goals( gwu_list )
   --  get a weighted goal value, representing how important a goal is, how much it is satisfied and whether its urgent   
   local weighted_goals = {}
   if gwu_list == nil then
      return -- not ready yet
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
