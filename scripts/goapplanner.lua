require 'general-utils/sets'
Peaque = require 'general-utils/peaque'

distance = {} -- purely to track so far for distance, not used to decide cheapest
predecessor = {}
action_taken = {}

function reset_all_tables(all_actions)
   for _, a in ipairs(all_actions) do
      distance[a] = 0;
   end
   predecessor = {}
   action_taken = {}
end

function generate_available_actions(all_actions, world_state)
   -- from all actions, which actions has precondition matching world state
   local available_a = {}
   for _, a in ipairs(all_actions) do      
      print('checking ' .. a.name)
      if is_subset(a:Precondition(), world_state) then
	 print('inserting ' .. a.name)
	 table.insert(available_a, a)
      end
   end
   return available_a
end

function goap_plan_action(world_state, goal_state, all_actions)
   reset_all_tables(all_actions)
   local pending_actions = Peaque:new()
   local available_actions = generate_available_actions(all_actions, world_state)
   print 'all available actions gen'   
   local world_set = Set.new(world_state)
   print 'new world state'
   
   for _, a in ipairs(available_actions) do
      local precond_set = Set.new(a:Precondition())
      local posteff_set = Set.new(a:PostEffect())
      print 'seting precond and post-cond'
      local node_state = world_set - precond_set + posteff_set
      print 'settting node'
      local a_node = Node(a, nil, a:Cost(), node_state)
      print 'create node success'
      distance[a] = a:Cost() -- pass world state and goal to calc heuristic
      predecessor[a] = nil
      pending_actions:push(a_node, a:Cost())
   end

   print 'now going to plan actions'
   
   while pending_actions:size() > 0 do
      -- for a single node
      node = pending_actions:pop()
      if is_subset(node.world_state, goal_node.current_state) then
	 print 'found goal state'
	 -- add next action and get all the way back to parent for sequence of action
      else
	 table.insert(action_taken, node.next_action)
	 local available_actions = generate_available_actions(all_actions, node.world_state)
	 for action in available_actions do
	    if action_taken[action] == nil then
	       cost = distance[node.next_action] + action:Cost()
	       
	       if distance[node.action] ~= nil -- need to set?
		  and cost < distance[node.action]
	       or not subset_exist(node, pending_actions) then -- pending_actions already - node
		  next_node = Node(node.current_state - action:Precondition() + action:PostEffect(), node, action, cost)
		  distance[next_node.action] = cost
		  pending_actions:push(node, cost)
		  table.insert(action_taken, action)
	       end
	    end
	 end
      end
   end
end

function is_subset(set, superset)
   local is_subset = true   
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
