local ItemSlot = require "widgets/itemslot"
require "goals/getforplayer"

---
-- Widget for each slot in the GatherCommandWidget
-- Very similar to ItemSlot except cannot drag and clicks inserts goal to companion.
-- Goal is GetForPlayer object associated with 'resource'
-- @param atlas the animation atlas
-- @param bgim the background image
-- @param owner the owning character (player)
-- @param resource the resource to gather associated with this slot
-- @param target the character that will carry out the command
-- @param commandwidget the parent GatherCommandWidget
-- @class GatherCommandSlot
-- @see widgets/gathercommandwidget.GatherCommandWidget
local GatherCommandSlot = Class(ItemSlot, function (self, atlas, bgim, owner, resource, target, commandwidget)
   ItemSlot._ctor(self, atlas, bgim, owner)   
   self.owner = owner   
   self.item = resource   
   self.target = target
   self.goal = GetForPlayer(self.target, self.item)
   self.widget = commandwidget
end)

---
-- clicking calls Click
-- @param control controls
-- @param down whether pressed down
function GatherCommandSlot:OnControl(control, down)
   if down and control == CONTROL_ACCEPT then
      self:Click()
   end
end

---
-- Clicking pushes event 'insertgoal' to the companion
-- goal is inserted to get resource for player
function GatherCommandSlot:Click()      
   self.target:PushEvent('insertgoal',{goal=self.goal})
   self.widget:Close()
end

return GatherCommandSlot