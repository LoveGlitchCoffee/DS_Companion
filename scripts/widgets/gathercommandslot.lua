local ItemSlot = require 'widgets/itemslot'

local GatherCommandSlot = Class(ItemSlot, function (self, atlas, bgim, owner, resource)
   ItemSlot._ctor(self, atlas, bgim, owner)   
   self.owner = owner   
   self.item = resource
   print 'Constructed slot'
end)

function GatherCommandSlot:OnControl(control, down)
   if down and control == CONTROL_ACCEPT then
      self:Click()
   end
end

-- function not part of widget, is custom
function GatherCommandSlot:Click()
   print('clicked on ' .. self.item)
end

return GatherCommandSlot