require 'goapplanner'

require 'actions/gather'
require 'actions/build'
require 'actions/searchfor'
require 'actions/eat'

require 'general-utils/table_ops'

PlanActions = Class(BehaviourNode, function(self, inst)
		       BehaviourNode._ctor(self, 'PlanActions')
		       self.inst = inst			   
		       self.all_actions = {
			  Gather(inst, 'twigs'),
			  Gather(inst, 'cutgrass'),
			  Gather(inst, 'food'), -- generic
			  --SearchFor(inst, 'twigs'),
			  --SearchFor(inst, 'grass'),
			  --SearchFor(inst, 'food'), -- generic
			  Build(inst, 'trap'),
			  Eat(inst)
		       }
end)

local function generate_inv_state(inventory, state)	
   if not inventory:IsFull() then
      state['has_inv_spc'] = true
   end

   print('inventory item number start over ' .. tostring(inventory:GetNumSlots()))
   
   -- goal precond + not have enough or not have, need
   -- can get goal and calculate how many times to repeat
   for i=1,inventory:GetNumSlots() do
	  	local item = inventory:GetItemInSlot(i)
		if item then
			print(tostring(item))			
			if state[item.prefab] then
				print 'item exist in state'
	 			-- total stack size, not restricted by in-game
	 			if item.components.stackable then
	    			state[item.prefab] = state[item.prefab] + item.components.stackable.stacksize
	 			else
	    			state[item.prefab] = state[item.prefab] + 1
	 			end
			else
		 		if item.components.stackable then				
	    			state[item.prefab] = item.components.stackable.stacksize
		 		else					
	    			state[item.prefab] = 1
	 	 		end	
			   end
			local has_key = 'has' .. tostring(item.prefab)			
      	end	 
   	end
end

local function generate_items_in_view(state)
	local pt = GLOBAL.GetPlayer():GetPosition()
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50) -- make distance config
	for k,entity in pairs(ents) do
		if entity then
			-- unique key
		end
	end	
end

function PlanActions:generate_world_state()	
   local state = {}
	local inventory = self.inst.components.inventory
	generate_inv_state(inventory, state)
	--generate_items_in_view(state)
   return state
end

function PlanActions:Visit()
	local world_state = self:generate_world_state()
	print('\n')
   print('world state: ')
	printt(world_state)
	print('\n')
	-- local goal_state = self.inst.components.planholder.currentgoal:GetGoalState()
	local goal_state = {}
	goal_state['trap'] = 1
   local action_sequence = goap_backward_plan_action(world_state, goal_state, self.all_actions)
   self.inst:PushEvent('actionplanned', {a_sequence=action_sequence})
end
