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

local function generate_valid_actions(all_actions, world_state)
   -- from all actions, which actions has precondition matching world state
   local available_a = {}
   
   for _, a in ipairs(all_actions) do      
      if is_subset_key(a:PostEffect(), world_state) then         
         table.insert(available_a, a)
      end
   end
   return available_a
end

local function calc_repeats_needed(node_state, world_state, action)
   -- calculate number of time needed to repeat an action
   -- in order for to get number of items in node_state (precondition set to node)
   -- this only triggers upon valid action
   local repeats = 1 -- default one for actions that is not 'repeatable'      
   if action.item then -- having item mean its repeatable (might change)      
      local item = action.item      
      if node_state[item] then         
         if world_state[item] then            
            repeats = node_state[item] - world_state[item]
         else            
            repeats = node_state[item]
         end
      end
   end
   return repeats
end

-- ALL GOALS MUST ONLY PRECOND HAVE OF 1
function goap_backward_plan_action(world_state, goal_state, all_actions)   
   reset_all_tables(all_actions)
   local pending_actions = Peaque:new()
   local valid_actions = generate_valid_actions(all_actions, goal_state)   
   local goal_set = Set.new(goal_state)

   print('goal is: ')
   print(tostring(goal_set))
   print("\n")

   for _, a in ipairs(valid_actions) do      
      local precond_set = Set.new(a:Precondition())
      local posteff_set = Set.new(a:PostEffect())      
      local node_state = goal_set - posteff_set + precond_set      
      local a_node = Node(a, a:Cost(), node_state)
      distance[a] = a:Cost() -- pass world state and goal to calc heuristic
      predecessor[a] = nil
      pending_actions:push(a_node, a:Cost())
   end   

   while pending_actions:size() > 0 do
      -- for a single node
      local node = pending_actions:pop()
      print('.' .. '\n')
      print('looking at ' .. tostring(node.next_action))

      -- backwards so check if satisfy world state
      if is_subset(node.world_state, world_state) then
         print 'found world state\n'
         -- add next action and get all the way back to parent for sequence of action
         local found_node = node
         local action_sequence = {}
         while predecessor[found_node] do            
            table.insert(action_sequence, #action_sequence+1, found_node.next_action)
            found_node = predecessor[found_node]
         end
         table.insert(action_sequence, #action_sequence+1, found_node.next_action) -- insert last action         
         printt(action_sequence)
         return action_sequence
      else
         print 'not world state'
         table.insert(action_taken, node.next_action)
         print 'current world state'
         printt(node.world_state)
         local available_actions = generate_valid_actions(all_actions, node.world_state)
         
         printt(available_actions)
         for _, action in ipairs(available_actions) do
            if action_taken[action] == nil then
               print('never tried this action: ', action.name)

               local repeats = calc_repeats_needed(node.world_state, world_state, action)
               print('repeating this action ' .. tostring(repeats))

               local cost = distance[node.next_action] + (action:Cost() * repeats) -- gotta do soething bout this

               if cost < distance[action] or not pending_actions:is_exist(action)  then -- pending_actions already - node
                  local precond = Set.new(action:Precondition())
                  local posteffect = Set.new(action:PostEffect())
                  local new_state = node.world_state - posteffect                  
                  print('state of world up till now ')
                  printt(node.world_state)                                 
                  
                  -- repeats is how any times to repeat this action,
                  -- considering the current world state
                  -- in order to reach this node's precondition
                  local next_node = node
                  -- never have to check if repeats = 0, would have been caught
                  -- and treated as found path
                  -- need to fix cost at some point
                  
                  for i=1,repeats do
                     print ('inserting action ' .. tostring(action) .. ' with parent ' .. tostring(next_node.next_action))
                     local new_node = Node(action, cost, new_state + precond)                     
                     predecessor[new_node] = next_node
                     next_node = new_node
                     -- REMEMBER its the no of times, not actual test, cba to make it nice rn
                  end
                                                                     
                  distance[next_node.next_action] = cost
                  pending_actions:push(next_node, cost)                  
               end
            else
               print 'aciton already taken'
            end
         end
      end
   end   
   return {} -- no plan found
end

Node = Class(function (self, next_action, cost, world_state)
   self.next_action = next_action   
   self.cost = cost -- of next action
   self.world_state = world_state -- of next_action
end)
