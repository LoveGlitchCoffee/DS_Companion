require 'general-utils/sets.lua'
require 'general-utils/peaque.lua'

distance = {} -- purely to track so far for distance, not used to decide cheapest
predecessor = {}
action_taken = {}

function reset_all_tables(all_actions)
   for a in all_actions do
      distance[a] = 0;
   end
   predecessor = {}
   action_taken = {}
end

function goap_plan_action(world_state, goal_state, all_actions)

   reset_all_tables(all_actions)

   local pending_actions = {} -- priority queue
   local available_actions = generate_available_actions(all_actions, world_state)
   world_set = Sets.new(world_state)
   
   for a in available_actions do      
      precond_set = Sets.new(a:Precondition())
      posteff_set = Sets.new(a:Posteffect())
      
      a_node = Node(a, nil, a:Cost(), world_set - precond_set + posteff_set)
      distance[a] = a:Cost() -- pass world state and goal to calc heuristic
      predecessor[a] = nil
      table.insert(pending_actions, a) -- change to priorityqueue.add
   end
   
   while #pending_actions > 0 do
      -- for a single node
      node = pending_actions.remove(1, pending_actions)
      if subset(node.world_state, goal_node.current_state) then
	 print 'found'
	 -- add next action and get all the way back to parent for sequence of action
      else
	 table.insert(action_taken, node.next_action)
	 local available_actions = generate_available_actions(all_actions, node.world_state)
	 for action in available_actions do
	    if action not in action_taken then
	       cost = distance[node.next_action] + action:Cost()
	       
	       if distance[node.action] ~= nil -- need to set?
		  and cost < distance[node.action]
	       or not subset_exist(node, pending_actions) then -- pending_actions already - node
		  next_node = Node(node.current_state - action:Precondition + action:Posteffect, node, action, cost)
		  distance[next_node.action] = cost
		  table.insert(pending_actions, node) -- no priority
		  table.insert(action_taken, action)
	       end
	    end
	 end
      end
   end
end

function subset(set, superset)
   is_subset = true
   for k, _ in pairs(set) do
      if superset[k] == nil then
	 is_subset = false
	 break
      end
   end
   return is_subset
end

Node = Class(function (next_action, parent_action, cost, world_state)
      self.next_action = next_action
      self.parent_action = parent_action
      self.cost = cost -- of next action
      self.world_state = world_state -- of next_action
end)
-- #TODO put == in meta table
