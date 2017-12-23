local Widget = require 'widgets/widget'
local ImageButon = require 'widgets/imagebutton'
local Image = require 'widgets/image'
local UIAnim = require 'widgets/uianim'

local GatherCommandWidget = Class(Widget, function(self, owner)   
   Widget._ctor(self, "GatherCommand")
   local scale = .6   
   self:SetScale(scale,scale,scale)
   self.owner = owner
   self:SetPosition(0, 0, 0)
   self.slotsperrow = 3 -- not used
   self.resource = {}
   self.isopen = false

   self.bganim = self:AddChild(UIAnim()) -- background anim   
end)

local slotpos_3x3 = {}
local threerowpix = 80
for y=2, 0, -1 do
   for x=0, 2 do
      table.insert(slotpos_3x3, Vector3(threerowpix*x-threerowpix*2+threerowpix, threerowpix*y-threerowpix*2+threerowpix,0))
   end   
end

local icons = {
   'cutgrass',
   'flint',
   'rocks',
   'twigs',
   'log',
   'carrot',
   'berries',
   'ice',
   'goldnugget'
}

function GatherCommandWidget:Open()   
   self:Close()
   -- self:StartUpdating()
   self.bganim:GetAnimState():SetBank("ui_chest_3x3")
   self.bganim:GetAnimState():SetBuild("ui_chest_3x3")   

   self:SetPosition(Vector3(700,700,0)) -- not relative to player
   
   self.isopen = true
   self:Show()   
   self.bganim:GetAnimState():PlayAnimation("open")   
   
   local n = 1
   for k,v in pairs(slotpos_3x3) do
      error('setting tile')
      local res = ImageButton('images/hud.xml', "inv_slot_spoiled.tex","inv_slot.tex","inv_slot_spoiled.tex","inv_slot_spoiled.tex","inv_slot_spoiled.tex")
      self.resource[n] = self:AddChild(res)
      res:SetPosition(v)
      -- res:SetOnClick()
      local resimage = Image('images/inventoryimages.xml', icons[n]..'.tex')
      res:AddChild(resimage)

      n = n + 1
   end   
end

function GatherCommandWidget:Close()
   if self.isopen then
      self:StopUpdating()      
   end
end

function GatherCommandWidget:OnUpdate(dt)
	if self.isopen and self.owner then	
	   local distsq = self.owner:GetDistanceSqToInst(self.container)
	   if distsq > 3*3 then	
	      self:Close()	
      end	
   end
end

return GatherCommandWidget