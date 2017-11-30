require 'goapplanner'
require 'actions/gather'
require 'actions/eat'

PlanActions = Class(BehaviourNode, function(self, inst)
		       BehaviourNode._ctor(self, 'PlanActions')
			   self.inst = inst			   
		       self.all_actions = {
			  Gather(inst, 'twigs'),
			  Gather(inst, 'food'), -- generic
			  Eat(inst)
		       }
end)

function PlanActions:generate_world_state()	
	local res = {}
	if not self.inst.components.inventory:IsFull() then				
		res['has_inv_spc'] = true		
	end
	return res
end

function PlanActions:Visit()
   print('planning action')
   local world_state = self:generate_world_state()
   print ('genrate world state')      
   local goal_state = self.inst.components.planholder.currentgoal:GetGoalState()
   print 'generate goal state'
   local action_sequence = goap_plan_action(world_state, goal_state, self.all_actions)
   self.inst:PushEvent('actionplanned', {a_sequence=action_sequence})
end
