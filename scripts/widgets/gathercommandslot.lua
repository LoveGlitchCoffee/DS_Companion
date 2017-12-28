local ItemSlot = require 'widgets/itemslot'
require 'goals/getforplayer'

local GatherCommandSlot = Class(ItemSlot, function (self, atlas, bgim, owner, resource, target)
   ItemSlot._ctor(self, atlas, bgim, owner)   
   self.owner = owner   
   self.item = resource   
   self.target = target
end)

function GatherCommandSlot:OnControl(control, down)
   if down and control == CONTROL_ACCEPT then
      self:Click()
   end
end

-- function not part of widget, is custom
function GatherCommandSlot:Click()   
   local g = GetForPlayer(self.target, self.item)
   self.target:PushEvent('insertgoal',{goal=g})
end

return GatherCommandSlot