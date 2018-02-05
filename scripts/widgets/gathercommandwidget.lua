require 'general-utils/debugprint'
require 'general-utils/table_ops'
require("general-utils/config")
require 'class'
local Widget = require 'widgets/widget'
local UIAnim = require 'widgets/uianim'
local GatherCommandSlot = require 'widgets/gathercommandslot'
local GatherCommandTile = require 'widgets/gathercommandtile'
local ItemTile = require 'widgets/itemtile'

local InvSlot = require 'widgets/invslot'

local GatherCommandWidget = Class(Widget, function(self, owner, target)
   Widget._ctor(self, "GatherCommand")
   local scale = .7
   self:SetScale(scale,scale,scale)
   self.owner = owner   
   self.target = nil
   self:SetPosition(0, 0, 0)   
   self.gatherable = {}
   self.isopen = false
   self.target = target
      
   self.bganim = self:AddChild(UIAnim()) -- background anim   
end)

local slotpos_3x3 = {}
local threerowpix = 80
for y=2, 0, -1 do
   for x=0, 2 do
      table.insert(slotpos_3x3, Vector3(threerowpix*x-threerowpix*2+threerowpix, threerowpix*y-threerowpix*2+threerowpix,0))
   end   
end

local resource = {
   'cutgrass',
   'flint',
   'rocks',
   'twigs',
   'log',
   'carrot',
   'berries',
   'silk',
   'goldnugget'
}

function GatherCommandWidget:Open(target)   
   self:Close()
   self:StartUpdating()
   self.bganim:GetAnimState():SetBank("ui_chest_3x3")
   self.bganim:GetAnimState():SetBuild("ui_chest_3x3")   

   self:SetPosition(Vector3(200,0,0)) -- not relative to player
   
   self.isopen = true
   self:Show()   
   self.bganim:GetAnimState():PlayAnimation("open")   
   
   -- each command
   local n = 1
   for k,v in pairs(slotpos_3x3) do
      self.gatherable[n] = self:AddChild(GatherCommandSlot('images/hud.xml', 'inv_slot.tex', self.owner, resource[n], self.target))
      self.gatherable[n]:SetPosition(v)      
      self.gatherable[n]:SetTile(GatherCommandTile(resource[n]))
      
      n = n + 1
   end
   
   self.target = target
end

function GatherCommandWidget:Close()
   if self.isopen then
      self:StopUpdating()
      for k,v in pairs(self.gatherable) do
         v:Kill()
      end
      self.gatherable = {} -- reset
      self.bganim:GetAnimState():PlayAnimation('close')
      self.isopen = false
   end
end

function GatherCommandWidget:OnUpdate(dt)
   if self.isopen and self.owner then      
	   local distsq = self.owner:GetDistanceSqToInst(self.target)
	   if distsq > DISTANCE_BEFORE_LOSE * DISTANCE_BEFORE_LOSE then
	      self:Close()	
      end	
   end
end

return GatherCommandWidget