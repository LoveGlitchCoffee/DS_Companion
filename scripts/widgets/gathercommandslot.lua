local ItemSlot = require 'widgets/itemslot'

local GatherCommandSlot = Class(ItemSlot, function (self, atlas, bgim, owner)
   ItemSlot._ctor(self, atlas, bgim, owner)   
   self.owner = owner
end)

function GatherCommandSlot:Click()
   print 'HAHAHA'
end

return GatherCommandSlot