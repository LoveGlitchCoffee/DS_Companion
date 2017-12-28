require 'behaviours/selectgoal'
require 'behaviours/planactions'
require 'behaviours/goapsequencenode'
require 'goals/stayfull'
require 'goals/stayhealthy'

require 'brains/utils'
require 'behaviours/debug'

require 'general-utils/table_ops'
require 'general-utils/debugprint'

local GoalBasedBrain = Class(Brain, function (self, inst)
	Brain._ctor(self, inst)
	self.gwu_list = {}	
end)


local function initialise_gwu(inst)
   -- Add all goals to the list, for now weight is always 1 (most important)
   local gwu_list = {}
   local healthy = goal_tuple(StayHealthy(inst), 1)
   local full = goal_tuple(StayFull(inst), 1)
      
   gwu_list['healthy'] = healthy
   gwu_list['full'] = full
   -- table.insert(gwu_list, 1, healthy)
   -- table.insert(gwu_list, 2, full)   
   
   return gwu_list
end

local function onNextGoalFound(inst, data)    
   inst.components.planholder.currentgoal = data.goal
   info('DECIDED ON GOAL ' .. tostring(inst.components.planholder.currentgoal) .. '\n')
end

local function onActionPlanned(inst, data)   
   if data.a_sequence ~= nil then
      local a_sequence = data.a_sequence
      local plan = {}
      for a=1,#a_sequence do
         info('putting in plan' .. tostring(a_sequence[a]))
         table.insert(plan, #plan+1, a_sequence[a]:Perform())
      end
      info('.\n')
      inst.components.planholder.actionplan = plan
   end
end

local function onInsertGoal(inst, data)   
   local goal = data.goal   
   local name = goal.name
   local g = goal_tuple(goal, 1) -- in proto following orders is important so 1
   inst.brain.gwu_list[name] = g   
   -- currently, this goal is first considered in the next iteration
end

local function onDropGoal(inst, goalname)
   error('GOAL DROPPED '..goalname)
   inst.brain.gwu_list[goalname] = nil
end

function GoalBasedBrain:OnStart()   
   self.gwu_list = initialise_gwu(self.inst)
   
   self.inst:ListenForEvent('nextgoalfound', onNextGoalFound)
   self.inst:ListenForEvent('actionplanned', onActionPlanned)   
   self.inst:ListenForEvent('insertgoal', onInsertGoal)
   self.inst:ListenForEvent('dropgoal', onDropGoal)
   
   self.inst.components.inventory:GiveItem(SpawnPrefab('cutgrass'))
   self.inst.components.inventory:GiveItem(SpawnPrefab('cutgrass'))
   self.inst.components.inventory:GiveItem(SpawnPrefab('cutgrass'))
   --print(tostring(self.inst.components.inventory:FindItem(function(item)
   --     return true
   -- end
   -- )))   
   
   local root = PriorityNode(
      {         
         -- maybe put this in if node     
         SelectGoal(self.inst, function () return self.gwu_list end),
         PlanActions(self.inst),
         IfNode(function() return self.inst.components.planholder.actionplan end, 'HasPlan',
         GOAPSequenceNode(function() return self.inst.components.planholder.actionplan end))
         
         --if goal is same then dun come up with new plan?      
         -- need to clean action plan
      }, 5)
   self.bt = BT(self.inst, root)
end

return GoalBasedBrain
