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

function PlanActions:Visit()
   goap_plan_action({has_inv_spc=true}, {eaten=true}, self.all_actions) -- test with simple world state
   self.status = SUCCESS
end
