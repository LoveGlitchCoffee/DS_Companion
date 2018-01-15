require 'goapplanner'

require 'actions/gather'
require 'actions/gatherfood'
require 'actions/build'
require 'actions/searchfor'
require 'actions/searchforresource'
require 'actions/eat'
require 'actions/give'
require("actions/followplayeraction")
require 'actions/givefood'
require("actions/attack")

require 'general-utils/table_ops'
require 'general-utils/debugprint'

local ALL_ACTIONS = nil

function populate_actions(inst)
	local player = GetPlayer()	
	ALL_ACTIONS = {
      FollowPlayerAction(inst, player),
      Gather(inst, 'twigs'),
      Gather(inst, 'cutgrass'),
		Gather(inst, 'carrot'),
		Gather(inst, 'flint'),
		GatherFood(inst, 'carrot'), -- special case
		GatherFood(inst, 'berries'),
		GatherFood(inst, 'meat'),
		GatherFood(inst, 'froglegs'),
      Give(inst, 'twigs', player),
      Give(inst, 'cutgrass', player),
		Give(inst, 'carrot', player),
		Give(inst, 'flint'),	
		GiveFood(inst, 'carrot', player),
		GiveFood(inst, 'berries', player),
		GiveFood(inst, 'meat', player),
		GiveFood(inst, 'froglegs', player),
      SearchForResource(inst, 'twigs'),
      SearchForResource(inst, 'cutgrass'), -- need to make SearchForResource
		SearchForResource(inst, 'carrot'),
		SearchFor(inst, 'pigman'),
		SearchFor(inst, 'frog'),
		-- SearchFor(inst, 'meat'), -- for testing. rn wnat to kill to get it
		SearchFor(inst, 'flint'),
		Build(inst, 'trap'),
		Build(inst, 'rope'),
		Build(inst, 'spear'),
		Attack(inst, 'pigman'),
		Attack(inst, 'frog')
      --Eat(inst)
	}
end

Q_MATRICES = 
{
	-- these should be exact name of goals
	'KeepPlayerFull'={},
	'FollowPlayer'={},
	'GetForPlayerlog'={},
	'GetForPlayertwigs'={},
	'GetForPlayercutgrass'={},
	'GetForPlayerrocks'={},
	'GetForPlayercarrot'={},
	'GetForPlayerberries'={},
	'GetForPlayersilk'={},
	'GetForPlayergoldnugget'={},
	'GetForPlayerflint'={}
}

R_MATRICES = 
{
	-- these should be exact name of goals
	'KeepPlayerFull'={},
	'FollowPlayer'={},
	'GetForPlayerlog'={},
	'GetForPlayertwigs'={},
	'GetForPlayercutgrass'={},
	'GetForPlayerrocks'={},
	'GetForPlayercarrot'={},
	'GetForPlayerberries'={},
	'GetForPlayersilk'={},
	'GetForPlayergoldnugget'={},
	'GetForPlayerflint'={}
}

function populatematrices(matrices)
	-- populate each goal matrix with
	-- action x action matrix
	if ALL_ACTIONS then
	   for k,v in pairs(matrices) do
	   	-- each k is a name, v is a matrix
			for i,kone in ipairs(ALL_ACTIONS) do
				v[kone.name]={}
				for j,ktwo in ipairs(ALL_ACTIONS) do
					if i == j then -- hopefully works
                  error('no transition possible')
					else
                  v[kone.name][ktwo.name] = 0
					end
				end
			end
		end
	else
		error('Actions not populated, reward will not work')
	end
end

function generate_inv_state(inventory, state)	
   if not inventory:IsFull() then
      state['has_inv_spc'] = true
   end

   -- info('inventory item number start over ' .. tostring(inventory:GetNumSlots()))
   
   -- goal precond + not have enough or not have, need
   -- can get goal and calculate how many times to repeat
   for i=1,inventory:GetNumSlots() do
	  	local item = inventory:GetItemInSlot(i)
		if item then
			info(tostring(item))
			if state[item.prefab] then
				info('item exist in state')
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
			if has_v(item.prefab, WEAPONS) then
				state['has_weapon'] = true -- but not equipped
			end			
			--local has_key = 'has' .. tostring(item.prefab)			
      end	 
	end
	
	for k,v in pairs(inventory.equipslots) do
		if has_v(v.prefab, WEAPONS) then
         state['has_weapon'] = true -- only valid way rn (hacky)
		end
	end
end

function generate_items_in_view(inventory, state, inst)
	-- problem is see items in inventory
	local pt = inst:GetPosition()
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 7) -- make distance config		
	for k,entity in pairs(ents) do
		if entity then
         if entity ~= inst then
            info('see ' .. tostring(entity))
				local entityname = entity.prefab
				
            if entity.components.pickable then
               entityname = entity.components.pickable.product -- so gather works
				end

				if inventory:FindItem(function (invItem) return invItem == entity end) then
					info('item is part of inventory')
				else
					local seenkey = ('seen_' .. entityname)				
					state[seenkey] = true
					info(seenkey)
				end				
			end
		end
	end	
end

function generate_world_state(inst)	
   local state = {}
	local inventory = inst.components.inventory
	generate_inv_state(inventory, state)
	generate_items_in_view(inventory, state, inst)
   return state
end

function planactions(inst, goal)
	local world_state = generate_world_state(inst)
	info('.\n')
   info('world state: ')
	--printt(world_state)
	info('.\n')
	--local goal_state = goal:GetGoalState()
	local goal_state = {froglegs=1}
	local action_sequence = goap_backward_plan_action(world_state, goal_state, ALL_ACTIONS)
	
	if #action_sequence > 0 then
		--error('succeed')
		return action_sequence
	end
	return nil
end
