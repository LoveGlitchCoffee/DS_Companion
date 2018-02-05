require 'general-utils/sets'
require 'general-utils/table_ops'
Peaque = require 'general-utils/peaque'
require 'general-utils/debugprint'
require("brains/brainutils")
require("brains/qlearner")

distance = {} -- purely to track so far for distance, not used to decide cheapest
predecessor = {}
action_taken = {}

local function reset_all_tables(all_actions)
   for _, a in ipairs(all_actions) do      
      distance[a] = math.huge
   end
   predecessor = {}
   action_taken = {}
end

local function generate_valid_actions(all_actions, world_state)
   -- from all actions, which actions has precondition matching world state
   local available_a = {}

   for _, a in ipairs(all_actions) do
      if is_satisfykey(a:PostEffect(), world_state) then
         info('can generate this action: ' .. tostring(a))
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
   if repeats <= 0 then
      info('repeats is less than 0')
      repeats = 1 -- otherwise infinite loop where used
   end
   return repeats
end

-- ALL GOALS MUST ONLY PRECOND HAVE OF 1
function goap_backward_plan_action(world_state, goal, all_actions)
   reset_all_tables(all_actions)
   local pending_actions = Peaque:new()
   local goalstate = goal:GetGoalState()
   -- local goalstate = {seen_fish=true} -- for testing
   local valid_actions = generate_valid_actions(all_actions, goalstate)   
   local goal_set = Set.new(goalstate)

   --info('GOAL')
   --info(tostring(goal_set))
   --info('GOAL')

   for _, a in ipairs(valid_actions) do
      local precond_set = Set.new(a:Precondition())
      local posteff_set = Set.new(a:PostEffect())
      local node_state = goal_set - posteff_set + precond_set
      local cost = 0 -- because immediate hits goals state (hoping peaque is smaller first)
      local a_node = Node(a, cost, node_state)
      distance[a] = cost -- pass world state and goal to calc heuristic      
      predecessor[a] = nil
      pending_actions:push(a_node, cost)
   end

   --info('STARTING PENDING ACTIONS')
   --for i=1,#pending_actions.A do
   --   info('pending action')
   --   print(tostring(pending_actions.A[i].data.next_action))
   --   info('end pending action')
   --end

   while pending_actions:size() > 0 do
      -- for a single node
      local node = pending_actions:pop()
       info('.' .. '\n')
       local predtest = nil
       if predecessor[node] then
          predtest = predecessor[node].next_action
       end
       info('.\nlooking at ' .. tostring(node.next_action)..' predecessor '..tostring(predtest))
       info('wold sate')
       -- printt(world_state)

      -- backwards so check if satisfy world state
      if is_satisfystate(node.world_state, world_state) then
         info('found world state\n')
         -- add next action and get all the way back to parent for sequence of action
         local found_node = node
         local action_sequence = {}         
         while predecessor[found_node] do
            table.insert(action_sequence, #action_sequence+1, found_node.next_action)
            found_node = predecessor[found_node]
         end         
         table.insert(action_sequence, #action_sequence+1, found_node.next_action) -- insert last action
         -- printt(action_sequence)
         return action_sequence
      else
         info('not world state')
         table.insert(action_taken, node.next_action)
         info('Precondition when at '..tostring(node.next_action))
         -- printt(node.world_state)         
         local available_actions = generate_valid_actions(all_actions, node.world_state)
         info('available actions generated')
         --printt(available_actions)
         for _, action in ipairs(available_actions) do
            if action_taken[action] == nil then
               local repeats = calc_repeats_needed(node.world_state, world_state, action)
               info('repeating this action ' .. tostring(repeats))
               --info('previous node: '..tostring(node.next_action))
               --info('cost '..tostring(distance[node.next_action]))
               --info('current action: '..tostring(action))

               local cost = 0
               local qcost = getcost(goal.name, action.name)
               --printt(distance)               
               info('cost of '..action.name..':'..tostring(action:Cost()))
               cost = distance[node.next_action] + ((100-qcost) * repeats) + action:Cost()               
               info('cost of action so far: '..tostring(distance[action]))

               if cost < distance[action] or not pending_actions:is_exist(action)  then -- pending_actions already - node
                  local precond = Set.new(action:Precondition())
                  local posteffect = Set.new(action:PostEffect())
                  local new_state = node.world_state - posteffect
                  info('state of world up till now ')
                  -- printt(node.world_state)

                  -- repeats is how any times to repeat this action,
                  -- considering the current world state
                  -- in order to reach this node's precondition
                  local next_node = node
                  -- never have to check if repeats = 0, would have been caught
                  -- and treated as found path
                  -- need to fix cost at some point

                  for i=1,repeats do
                     info('inserting action ' .. tostring(action) .. ' with parent ' .. tostring(next_node.next_action))
                     local new_node = Node(action, cost, new_state + precond)
                     predecessor[new_node] = next_node
                     next_node = new_node
                     -- REMEMBER its the no of times, not actual test, cba to make it nice rn
                  end
                  
                  distance[next_node.next_action] = cost
                  pending_actions:push(next_node, cost)
               end
            else
               info('action already taken')
            end
         end
      end
   end
   info('no plan')
   return {} -- no plan found
end

Node = Class(function (self, next_action, cost, world_state)
   self.next_action = next_action
   self.cost = cost -- of next action
   self.world_state = world_state -- of next_action
end)
