require 'behaviours/selectgoal'
require 'behaviours/planactions'
require 'behaviours/goapsequencenode'
require 'goals/stayfull'
require 'goals/stayhealthy'

require 'brains/utils'
require 'behaviours/debug'

require 'general-utils/table_ops'

local GoalBasedBrain = Class(Brain, function (self, inst)
	Brain._ctor(self, inst)
	self.gwu_list = {}	
end)


local function initialise_gwu(inst)
   -- Add all goals to the list, for now weight is always 1 (most important)
   local gwu_list = {}
   local healthy = goal_tuple(StayHealthy(inst), 1)
   local full = goal_tuple(StayFull(inst), 1)
      
   table.insert(gwu_list, 1, healthy)
   table.insert(gwu_list, 2, full)   
   
   return gwu_list
end

local function onNextGoalFound(inst, data)    
   inst.components.planholder.currentgoal = data.goal
   print('DECIDED ON GOAL ' .. tostring(inst.components.planholder.currentgoal) .. '\n')   
end

local function onActionPlanned(inst, data)   
   if data.a_sequence ~= nil then
      local a_sequence = data.a_sequence
      local plan = {}
      for a=1,#a_sequence do
         print('putting in plan' .. tostring(a_sequence[a]))
         table.insert(plan, #plan+1, a_sequence[a]:Perform())
      end
      print '.\n'
      inst.components.planholder.actionplan = plan
   end
end

function GoalBasedBrain:OnStart()   
   self.gwu_list = initialise_gwu(self.inst)
   
   self.inst:ListenForEvent('nextgoalfound', onNextGoalFound)
   self.inst:ListenForEvent('actionplanned', onActionPlanned)   
   
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
         SelectGoal(self.inst, self.gwu_list),
         PlanActions(self.inst),         
         IfNode(function() return self.inst.components.planholder.actionplan end, 'HasPlan',
         GOAPSequenceNode(function() return self.inst.components.planholder.actionplan end))
         -- Debug(self.inst, function() return self.inst.components.planholder.actionplan end)) -- it reverts back to constructor values. not a component thing
         -- works if i use it as a lambda. i.e. wrap in a function
         -- using global doesn't work, try self and wrap function?
         -- can't do it from here but can do it inside behaviours
         -- probably to do with when this was ran, planholder is nothing - confirmed.
         -- so only way is to make it when visit() is called

         -- SequenceNode(self.inst.components.planholder.actionplan)
         --if goal is same then dun come up with new plan?      
         -- need to clean action plan
      }, 5)
   self.bt = BT(self.inst, root)
end

return GoalBasedBrain
