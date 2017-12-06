require 'general-utils/sets'
require 'general-utils/table_ops'
Peaque = require 'general-utils/peaque'

distance = {} -- purely to track so far for distance, not used to decide cheapest
predecessor = {}
action_taken = {}

local function reset_all_tables(all_actions)
   for _, a in ipairs(all_actions) do
      distance[a] = 0;
   end
   predecessor = {}
   action_taken = {}
end

local function generate_available_actions(all_actions, world_state)
   -- from all actions, which actions has precondition matching world state
   local available_a = {}
   for _, a in ipairs(all_actions) do
      if is_subset(a:Precondition(), world_state) then
	 table.insert(available_a, a)
      end
   end
   return available_a
end

local function calculate_state_rep(action_precond, action_postcond, world_state, goal_state)
      local repeats
      -- for having stack of item, calculate how many repitions
      -- for sufficient stack size

      -- only catering for gather rn. not catering for down the linw
      -- requiring 2 or more ingredients for recipe
      -- e.g. science machine need 2 doodads, 
      -- we subtract the need to make doodad only occur once,
      -- but by that time we already finish gather grass, but not enough for 2 doodads
      -- can break down goal into most base recipe and Perform puts it all together
      for k, v in pairs(action_postcond) do
            if type(v) == 'number' then
               if goal_state[k] then
                  if world_state[k] then
                     repeats = goal_state[k] - world_state[k]
                  else
                     repeats = goal_state[k]
                  end
               end
            end
      end

      for k, v in pairs(goal_state) do
            if type(v) == 'number' then
                  if world_state[k] then
                        repeats = goal_state[k] - world_state[k]
                  else
                        repeats = goal_state[k]
                  end
            end

            if action_postcond[k] then
                  action_postcond[k] = repeats
            end
      end
end

function goap_plan_action(world_state, goal_state, all_actions)
   reset_all_tables(all_actions)
   local pending_actions = Peaque:new()
   local available_actions = generate_available_actions(all_actions, world_state)
   local world_set = Set.new(world_state)
   
   for _, a in ipairs(available_actions) do

      local precond_set = Set.new(a:Precondition())
      local posteff_set = Set.new(a:PostEffect())
      local node_state = world_set - precond_set + posteff_set
      local a_node = Node(a, nil, a:Cost(), node_state, 1)
      distance[a] = a:Cost() -- pass world state and goal to calc heuristic
      predecessor[a] = nil
      pending_actions:push(a_node, a:Cost())
   end

   -- print('FINISH INIT')

   -- now plan
   while pending_actions:size() > 0 do
      -- for a single node
      local node = pending_actions:pop()
      print('looking at ' .. tostring(node.next_action))
      if is_subset(node.world_state, goal_state) then
	 print 'found goal state'
	 -- add next action and get all the way back to parent for sequence of action
       local found_node = node
       local action_sequence = {}
	 while found_node ~= nil do          
          table.insert(action_sequence, 1, found_node.next_action)
          found_node = found_node.parent_node
       end
       return action_sequence
      else
	 table.insert(action_taken, node.next_action)
	 local available_actions = generate_available_actions(all_actions, node.world_state)
	 for _, action in ipairs(available_actions) do
	    if action_taken[action] == nil then
	       print('never tried this action: ', action.name)
	       local cost = distance[node.next_action] + action:Cost()
	      --  print 'IN DISTANCE?'
	      --  print(tostring(distance[node.next_action] ~= nil))
	      --  print 'COST LESS'
	      --  print(tostring(cost < distance[node.next_action]))
	       	       
	       if distance[node.next_action] ~= nil -- need to set?
		  and cost < distance[node.next_action]
             or not pending_actions:is_exist(action)  then -- pending_actions already - node              
              local precond = Set.new(action:Precondition())
              local postcond = Set.new(action:PostEffect())
              
              local state_rep = calc_state_rep(precond, postcond, node.world_state, goal_state)

              local next_node = Node(action, node, cost, state_rep.state, state_rep.repeats)
              print ('inserting action ' .. tostring(action) .. ' with parent ' .. tostring(node.next_action))
		  distance[next_node.next_action] = cost
		  pending_actions:push(next_node, cost)
		  -- table.insert(action_taken, action)
	       end
	    else
	       print 'aciton already taken'
	    end
	 end
      end
   end
   return {} -- no plan found
end

Node = Class(function (self, next_action, parent_node, cost, world_state, repeats)
      self.next_action = next_action
      self.parent_node = parent_node
      self.cost = cost -- of next action
      self.world_state = world_state -- of next_action
      self.repeats = repeats -- how many times action is repeated
end)
