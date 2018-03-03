require "brains/selectgoal"
require "brains/planactions"
require "behaviours/responsivegoapnode"
require "goals/stayfull"
require "goals/stayhealthy"
require "goals/followplayer"
require "goals/keepplayerfull"

require "brains/brainutils"
require "brains/qlearner"

require "generalutils/table_ops"
require "generalutils/debugprint"

---
-- Brain for companion
-- @param inst Instance to assign braing to
-- @class GoalBasedBrain
local GoalBasedBrain = Class(Brain, function (self, inst)
	Brain._ctor(self, inst)
   self.gwu_list = {}   
end)

---
-- initialises list consisting goal,weight tuples representing all goals
-- and their weighting to the character
-- @param inst instance assign goal, weight list to
-- @return initialised goal,weight list
local function initialise_gwu(inst)
   -- Add all goals to the list, for now weight is always 1 (most important)
   local player = GetPlayer()

   local gwu_list = {}
   --local stayhealthy = StayHealthy(inst)
   --local stayfull = StayFull(inst)
   local followPlayer = FollowPlayer(inst, player)
   local keepplayerfull = KeepPlayerFull(inst, player)
   
   --local healthy = goal_tuple(stayhealthy, 1)
   --local full = goal_tuple(stayfull, 1)
   local follow = goaltuple(followPlayer, 1)
   local keepfull = goaltuple(keepplayerfull, 1)

   --gwu_list[stayhealthy.name] = healthy
   --gwu_list[stayfull.name] = full
   gwu_list[followPlayer.name] = follow
   gwu_list[keepplayerfull.name] = keepfull

   return gwu_list
end

---
-- callback function when inserting a new goal to goal, weight list
-- usually called with user input
-- @param inst instance that holds the goal, weight list
-- @param data data from event consisting the goal to add
local function onInsertGoal(inst, data)
   local goal = data.goal
   local g = goaltuple(goal, 1) -- following commands is important so 1
   inst.brain.gwu_list[goal.name] = g   
end

---
-- callback function when dropping a goal from goal,weight list
-- @param inst instance holding the goal, weight list
-- @param data data from event consisting the goal to drop
local function onDropGoal(inst, data)
   local goalname = data.goalname
   error('GOAL DROPPED '..goalname)
   inst.brain.gwu_list[goalname] = nil
end

---
-- Assign this brain to behaviour tree
-- Brain only uses ResponsiveGOAPNode, no other Behaviour nodes
-- @see brains/responsivegoapnode.ResponsiveGOAPNode
function GoalBasedBrain:OnStart()
   self.gwu_list = initialise_gwu(self.inst)

   self.inst:ListenForEvent('insertgoal', onInsertGoal)
   self.inst:ListenForEvent('dropgoal', onDropGoal)   

   -- self.inst.components.inventory:GiveItem(SpawnPrefab('cutgrass'))
   -- self.inst.components.inventory:GiveItem(SpawnPrefab('cutgrass'))
   -- self.inst.components.inventory:GiveItem(SpawnPrefab('cutgrass'))
   -- self.inst.components.inventory:GiveItem(SpawnPrefab('cutgrass'))
   -- self.inst.components.inventory:GiveItem(SpawnPrefab('cutgrass'))
   -- self.inst.components.inventory:GiveItem(SpawnPrefab('cutgrass'))
   self.inst.components.inventory:GiveItem(SpawnPrefab('twigs'))
   self.inst.components.inventory:GiveItem(SpawnPrefab('twigs'))
   -- self.inst.components.inventory:GiveItem(SpawnPrefab('twigs'))
   -- self.inst.components.inventory:GiveItem(SpawnPrefab('twigs'))
   -- self.inst.components.inventory:GiveItem(SpawnPrefab('flint'))
   -- self.inst.components.inventory:Equip(SpawnPrefab('spear'))
   -- self.inst.components.inventory:Equip(SpawnPrefab('armorgrass'))
   

   local root = ResponsiveGOAPNode(self.inst, .25, function ()
      return self.gwu_list
   end)   
   self.bt = BT(self.inst, root)
end

---
-- On stop, remove all callbacks and stop all goal
function GoalBasedBrain:OnStop()
   self.inst:RemoveEventCallback('insertgoal', onInsertGoal)
   self.inst:RemoveEventCallback('dropgoal', onDropGoal)

   for _,v in pairs(self.gwu_list) do
      v.goal:OnStop()
   end
end

return GoalBasedBrain
