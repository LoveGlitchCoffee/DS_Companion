require 'goapplanner'
require 'actions/gather'
require 'actions/eat'

PlanActions = Class(BehaviourNode, function(self, inst, current_goal)
		       BehaviourNode._ctor(self, 'PlanActions')
			   self.inst = inst
			   self.current_goal = current_goal
		       self.all_actions = {
			  Gather(inst, 'twigs'),
			  Gather(inst, 'food'), -- generic
			  Eat(inst)
		       }
end)

function PlanActions:generate_world_state()
	local res = {}
	if not self.inst.components.inventory:IsFull() then
		res{has_inv_spc = true}		
	end	

	return res
end

function PlanActions:Visit()   
   local world_state = self:generate_world_state()
   local goal_state = self.current_goal:GetGoalState()
   action_sequence = goap_plan_action(world_state, goal_state, self.all_actions)
   self.inst:PushEvent('actionplanned', {a_sequence=action_sequence})
end
