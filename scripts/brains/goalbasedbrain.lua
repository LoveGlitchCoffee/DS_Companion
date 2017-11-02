require 'behaviours/selectgoal'
require 'goals/stayfull'
require 'goals/stayhealthy'

require 'brains/utils'

local GoalBasedBrain = Class(Brain, function (self, inst)
				Brain._ctor(self, inst)
				self.gwu_list = {}
end)


local function initialise_gwu(inst)
   -- Add all goals to the list, for now weight is always 1 (most important), urgency is 0.1 (but changes)
   local gwu_list = {}
   print('list init')
   local healthy = goal_tuple(StayHealthy(inst), 1, 0.1)
   local full = goal_tuple(StayFull(inst), 1, 0.1)
      
   table.insert(gwu_list, 1, healthy)
   table.insert(gwu_list, 2, full)

   print('placed goals in list')
   
   return gwu_list
end

function GoalBasedBrain:OnStart()
   print('Start thinking')
   self.gwu_list = initialise_gwu(self.inst)
   -- WORRY ABOUT SELECTING GOAL ONLY FOR NOW
   -- Sequence node, 1 child, behaviour select goal
   -- used self.inst.pushevent for custom events

   local root = PriorityNode(
      {
	 -- maybe put this in if node
	 SelectGoal(self.gwu_list)
	 -- sequence of behav in 'current sequence of actions'
      }, 1) -- repeat every 1 unit?
   self.bt = BT(self.inst, root)
end

return GoalBasedBrain
