local Image = require "widgets/image"
local Widget = require "widgets/widget"

local GatherCommandTile = Class(Widget, function(self, resource)
   Widget._ctor(self, "GatherCommandTile")
   self.item = resource

   --self.bg = self:AddChild(Image())
	--self.bg:SetTexture(HUD_ATLAS, "inv_slot_spoiled.tex")
	--self.bg:Hide()
   --self.bg:SetClickable(false)
   
   self.basescale = 1
   
   self.image = self:AddChild(Image('images/inventoryimages.xml', self.item..'.tex'))

end)

function GatherCommandTile:SetBaseScale(sc)
	self.basescale = sc
	self:SetScale(sc)
end

function GatherCommandTile:OnControl(control, down)
    self:UpdateTooltip()
    return false
end

function GatherCommandTile:UpdateTooltip()
	local str = self:GetDescriptionString()
	self:SetTooltip(str)
end

function GatherCommandTile:GetDescriptionString()
   return 'Gather ' .. self.resource
end

function GatherCommandTile:OnGainFocus()    
    self:UpdateTooltip()
end

return GatherCommandTile