local ItemSlot = require 'widgets/itemslot'
require 'goals/getforplayer'

local GatherCommandSlot = Class(ItemSlot, function (self, atlas, bgim, owner, resource, target)
   ItemSlot._ctor(self, atlas, bgim, owner)   
   self.owner = owner   
   self.item = resource   
   self.target = target
   self.goal = GetForPlayer(self.target, self.item)
end)

function GatherCommandSlot:OnControl(control, down)
   if down and control == CONTROL_ACCEPT then
      self:Click()
   end
end

-- function not part of widget, is custom
function GatherCommandSlot:Click()      
   self.target:PushEvent('insertgoal',{goal=self.goal})
end

return GatherCommandSlot