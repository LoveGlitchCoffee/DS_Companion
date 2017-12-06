require 'behaviours/selectgoal'
require 'behaviours/planactions'
require 'goals/stayfull'
require 'goals/stayhealthy'

require 'brains/utils'

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
   print(tostring(inst.components.planholder.currentgoal))   
end

local function onActionPlanned(inst, data)
   if data.a_sequence ~= nil then
      inst.components.planholder.actionplan = data.a_sequence
      printt(inst.components.planholder.actionplan)
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
	 RunAway(self.inst, "scarytoprey", 5, 7),
     -- maybe put this in if node     
     SelectGoal(self.inst, self.gwu_list),
     PlanActions(self.inst),
     IfNode(function() return #self.inst.components.planholder.actionplan > 0 end, 'has_plan',
         SequenceNode(
            self.inst.components.planholder.GenerateActionSequence()
      ))
      --if goal is same then dun come up with new plan?
      
      }, 5)
   self.bt = BT(self.inst, root)
end

return GoalBasedBrain
