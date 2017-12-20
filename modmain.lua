GLOBAL.CHEATS_ENABLED = true
GLOBAL.require( 'debugkeys' ) -- for debugging, ctrl+r to reload all scripts
local Vector3 = GLOBAL.Vector3
-- local GetPlayer = GLOBAL.GetPlayer

function SpawnSmartCompanion(player)   
   local smart_brain = GLOBAL.require 'brains/goalbasedbrain'

   local pos = Vector3(player.Transform:GetWorldPosition()) -- : is oo syntatic sugar to pass self
   local companion = GLOBAL.SpawnPrefab("forest/animals/perd")
   if companion and pos then
      print('dst smart companion is now running')
      companion:AddComponent('hunger')
      companion:AddComponent('planholder')
      -- companion:AddComponent('inventory')
      -- companion:RemoveComponent('sleeper')
      companion:SetBrain(smart_brain)
      companion.Transform:SetPosition(pos:Get())

      -- try remove component follower and leader and player
      
   end   
end


AddSimPostInit(SpawnSmartCompanion)
