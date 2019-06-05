PrefabFiles = {
   "companion"
}

GLOBAL.CHEATS_ENABLED = true
GLOBAL.require( 'debugkeys' ) -- for debugging, ctrl+r to reload all scripts
local Vector3 = GLOBAL.Vector3
local ACTIONS = GLOBAL.ACTIONS
local STRINGS = GLOBAL.STRINGS
local COLLISION = GLOBAL.COLLISION
--- local GetPlayer = GLOBAL.GetPlayer

-- set Gathering ----------------------------------------
STRINGS.ACTIONS.GATHERCOMMAND = "Command"

ACTIONS.GATHERCOMMAND = GLOBAL.Action({},-1, true)
ACTIONS.GATHERCOMMAND.fn = function(act)
   local targ = act.target
   if act.doer.HUD and targ.components.gatherminion then
      targ.components.gatherminion:Command(act.doer, act.target)
      return true
   end
end
ACTIONS.GATHERCOMMAND.str = STRINGS.ACTIONS.GATHERCOMMAND
ACTIONS.GATHERCOMMAND.strfn = function (act)
   return "Command"
end
ACTIONS.GATHERCOMMAND.id = "GATHERCOMMAND"
---------------------------------------------------------

function SpawnSmartCompanion(player)
   local pos = Vector3(player.Transform:GetWorldPosition()) -- : is oo syntatic sugar to pass self

   local companion = GLOBAL.SpawnPrefab("companion")
   print("SPAWN COMANION "..tostring(companion))
   if companion and pos then
      print('dst smart companion is now running')
      companion:AddTag('companion')
      --companion:RemoveComponent('leader')
      companion:RemoveTag('player')

      companion.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
      companion.Physics:ClearCollisionMask()
      companion.Physics:CollidesWith(COLLISION.WORLD)
      companion.Physics:CollidesWith(COLLISION.OBSTACLES)
      --companion:RemoveComponent('hunger') -- don't die            
            
      companion.Transform:SetPosition(pos:Get())

      -- try remove component follower and leader and player
   end
end

AddSimPostInit(SpawnSmartCompanion)
