require 'behaviours/selectgoal'
require 'goals/stayfull'
require 'goals/stayhealthy'

require 'brains/utils'

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

function GoalBasedBrain:OnStart()
   self.gwu_list = initialise_gwu(self.inst)
   -- WORRY ABOUT SELECTING GOAL ONLY FOR NOW
   -- Sequence node, 1 child, behaviour select goal
   -- used self.inst.pushevent for custom events
   
   local root = PriorityNode(
      {
	 RunAway(self.inst, "scarytoprey", 8, 18),
	 -- maybe put this in if node
	 SelectGoal(self.inst, self.gwu_list)
	 -- sequence of behav in 'current sequence of actions'
      }, 5)
   self.bt = BT(self.inst, root)
end

return GoalBasedBrain
