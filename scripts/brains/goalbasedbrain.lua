require 'behaviours/selectgoal'
require 'behaviours/planactions'
require 'goals/stayfull'
require 'goals/stayhealthy'

require 'brains/utils'

local function printt(t)
   for k, v in pairs(t) do
      print(tostring(k))
      print(tostring(v))
   end
end

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
end

local function onActionPlanned(inst, data)
   inst.components.planholder.actionplan = data.a_sequence
   printt(inst.components.planholder.actionplan)
end

function GoalBasedBrain:OnStart()
   self.gwu_list = initialise_gwu(self.inst)
   
   self.inst:ListenForEvent('nextgoalfound', onNextGoalFound)
   self.inst:ListenForEvent('actionplanned', onActionPlanned)
   
   -- Sequence node, 1 child, behaviour select goal   
   
   local root = PriorityNode(
      {
	 RunAway(self.inst, "scarytoprey", 5, 7),	 
     -- maybe put this in if node     
     SelectGoal(self.inst, self.gwu_list),
     PlanActions(self.inst)
	 -- sequence of behav in 'current sequence of actions'	 
      }, 5)
   self.bt = BT(self.inst, root)
end

return GoalBasedBrain
