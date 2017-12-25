local Image = require "widgets/image"
local Widget = require "widgets/widget"
local ItemTile = require 'widgets/itemtile'
require 'general-utils/debugprint'

local GatherCommandTile = Class(Widget, function(self, resource)
   Widget._ctor(self, "GatherCommandTile")
   self.image = self:AddChild(Image('images/inventoryimages.xml', resource..'.tex'))
   self.resource = resource
end)

--function GatherCommandTile:OnControl(control, down)
--    print('hovering over ' .. self.resource)
--    self:SetTooltip('Gather '..self.resource)
--    return false
--end

--function GatherCommandTile:GetDescriptionString()
--   local str = 'Gather '..self.item
--   return str
--end
--
function GatherCommandTile:OnGainFocus()
    self:SetTooltip('Gather '..self.resource)
end
--
--function GatherCommandTile:StartDrag()    
--end
--
--function GatherCommandTile:HasSpoilage()
--    return false
--end

return GatherCommandTile