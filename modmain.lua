GLOBAL.CHEATS_ENABLED = true
GLOBAL.require( 'debugkeys' ) -- for debugging, ctrl+r to reload all scripts
local Vector3 = GLOBAL.Vector3
local ACTIONS = GLOBAL.ACTIONS
local COLLISION = GLOBAL.COLLISION
-- local GetPlayer = GLOBAL.GetPlayer

-- set Gathering ----------------------------------------
ACTIONS.GATHERCOMMAND = GLOBAL.Action(-1, true)
ACTIONS.GATHERCOMMAND.fn = function(act)   
   local targ = act.target
   if act.doer.HUD and targ.components.gatherminion then
      targ.components.gatherminion:Command(act.doer, act.target)
      return true
   end
end
ACTIONS.GATHERCOMMAND.str = "Command to gather"
ACTIONS.GATHERCOMMAND.id = "GATHERCOMMAND"
---------------------------------------------------------

function SpawnSmartCompanion(player)   
   local smart_brain = GLOBAL.require 'brains/goalbasedbrain'

   local pos = Vector3(player.Transform:GetWorldPosition()) -- : is oo syntatic sugar to pass self
   local companion = GLOBAL.SpawnPrefab("wx78")
   if companion and pos then
      print('dst smart companion is now running')
      --companion:RemoveComponent('hunger') -- don't die
      companion:AddComponent('gatherminion')
      -- companion:RemoveComponent('inspectable')
      companion:AddComponent('clock')      
      --companion:SetStateGraph('SGperdcompanion')
      --companion:RemoveTag('player')
      --companion:RemoveComponent
      companion.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
      companion.Physics:ClearCollisionMask()
      companion.Physics:CollidesWith(COLLISION.WORLD)
      companion.Physics:CollidesWith(COLLISION.OBSTACLES)
      companion.components.locomotor.runspeed = 7
      companion.components.locomotor.walkspeed = 5
      -- companion:RemoveComponent('sleeper')
      companion:SetBrain(smart_brain)
      companion.Transform:SetPosition(pos:Get())      

      -- try remove component follower and leader and player
      
   end   
end

AddSimPostInit(SpawnSmartCompanion)
