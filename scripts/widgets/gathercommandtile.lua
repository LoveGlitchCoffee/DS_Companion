local Image = require "widgets/image"
local Widget = require "widgets/widget"
local ItemTile = require "widgets/itemtile"
require "generalutils/debugprint"

---
-- Widget to display a resource in a GatherCommandSlot
-- @param resource the resource to display
-- @class GatherCommandTile
-- @see GatherCommandSlot
local GatherCommandTile = Class(Widget, function(self, resource)
   Widget._ctor(self, "GatherCommandTile")
   self.image = self:AddChild(Image('images/inventoryimages.xml', resource..'.tex'))
   self.resource = resource
end)

---
-- Change tooltip to show what will be gather if clicked
function GatherCommandTile:OnGainFocus()
    self:SetTooltip('Gather '..self.resource)
end

return GatherCommandTile