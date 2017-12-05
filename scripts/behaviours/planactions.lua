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
   local inventory = self.inst.components.inventory
   if not inventory:IsFull() then
      res['has_inv_spc'] = true		
   end

   for i=1,inventory:GetNumSlots() do
      local item = inventory:GetItemInSlot(i)
      if res[item] then
	 -- total stack size, not restricted by in-game
	 if item.components.stackable then
	    res[item] = res[item] + item.components.stackable.stacksize
	 else
	    res[item] = res[item] + 1
	 end
      else
	 if item.components.stackable then
	    res[item] = item.components.stackable.stacksize
	 else
	    res[item] = 1
	 end
      end
	 
   end
   return res
end

function PlanActions:Visit()
   print('planning action')
   local world_state = self:generate_world_state()   
   local goal_state = self.inst.components.planholder.currentgoal:GetGoalState()   
   local action_sequence = goap_plan_action(world_state, goal_state, self.all_actions)
   self.inst:PushEvent('actionplanned', {a_sequence=action_sequence})
end
