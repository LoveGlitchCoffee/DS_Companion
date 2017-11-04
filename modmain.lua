GLOBAL.CHEATS_ENABLED = true
GLOBAL.require( 'debugkeys' ) -- for debugging, ctrl+r to reload all scripts
local Vector3 = GLOBAL.Vector3
-- local GetPlayer = GLOBAL.GetPlayer

function SpawnSmartCompanion(player)   
   local smart_brain = GLOBAL.require 'brains/goalbasedbrain'

   local pos = Vector3(player.Transform:GetWorldPosition()) -- : is oo syntatic sugar to pass self
   local abigail = GLOBAL.SpawnPrefab("wilson")
   if abigail and pos then
      print('dst smart companion is now running')
      abigail:SetBrain(smart_brain)
      abigail.Transform:SetPosition(pos:Get())
   end   
end


AddSimPostInit(SpawnSmartCompanion)
