require "generalutils/debugprint"
require "generalutils/table_ops"
require "generalutils/config"

local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local GatherCommandSlot = require "widgets/gathercommandslot"
local GatherCommandTile = require "widgets/gathercommandtile"

---
-- widget for the gathering command panel
-- allows for player to issue commands to companion to gather certain items
-- @param owner the owner of the widget, the player
-- @param target the target for commanding, the companion
-- @class GatherCommandWidget
local GatherCommandWidget = Class(Widget, function(self, owner, target)
   Widget._ctor(self, "GatherCommand")
   local scale = .7
   self:SetScale(scale,scale,scale)
   self.owner = owner   
   self:SetPosition(0, 0, 0)
   self.gatherable = {}
   self.isopen = false
   self.target = target

   self.bganim = self:AddChild(UIAnim()) -- background anim
end)

--- The layout for the slows in the command panel
local slotpos_3x3 = {}
local threerowpix = 80 -- distance between slots
-- initialise slots
for y=2, 0, -1 do
   for x=0, 2 do
      table.insert(slotpos_3x3, Vector3(threerowpix*x-threerowpix*2+threerowpix, threerowpix*y-threerowpix*2+threerowpix,0))
   end
end

--- resources to which commands can be issued to gather
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

---
-- defines what occur when opening the command panel
-- This handles animation as well as creating GatherCommandSlots, clickable widgets,
-- that issue orders
-- @param target the target to which commands will be issued to
-- @see GatherCommandSlot
-- @see GatherCommandTile
function GatherCommandWidget:Open(target)
   self:Close()
   self:StartUpdating()

   -- animation set
   self.bganim:GetAnimState():SetBank("ui_chest_3x3")
   self.bganim:GetAnimState():SetBuild("ui_chest_3x3")

   self:SetPosition(Vector3(200,0,0)) -- not relative to player

   self.isopen = true
   self:Show()
   self.bganim:GetAnimState():PlayAnimation("open")

   -- command slot for each resource
   local n = 1
   for k,v in pairs(slotpos_3x3) do
      self.gatherable[n] = self:AddChild(GatherCommandSlot('images/hud.xml', 'inv_slot.tex', self.owner, resource[n], self.target, self))
      self.gatherable[n]:SetPosition(v)
      -- tile image
      self.gatherable[n]:SetTile(GatherCommandTile(resource[n]))

      n = n + 1
   end

   self.target = target
end

---
-- defines what occur when close command panel
-- kills all related widget and plays close animation
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

---
-- Updating the component only checks if widget needs closing
-- widget closes if player and companion are far away from each other
-- @param dt delta time
function GatherCommandWidget:OnUpdate(dt)
   if self.isopen and self.owner then
	   local distsq = self.owner:GetDistanceSqToInst(self.target)
	   if distsq > DISTANCE_BEFORE_LOSE * DISTANCE_BEFORE_LOSE then
	      self:Close()
      end
   end
end

return GatherCommandWidget