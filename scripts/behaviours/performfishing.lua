require "generalutils/gameutils"
require "generalutils/config"

---
-- Custom fishing behaviour based that uses ACTIONS.FISH,
-- original fishing behaviour is coupled with player so this is needed.
-- @param inst Instance to do fishing
-- @class PerformFishing
PerformFishing = Class(BehaviourNode, function(self, inst)
   BehaviourNode._ctor(self, "PerformFishing")
   self.inst = inst

   -- function for reeling in fish, actual progression of fishing
   self.reel = function (inst, data)
      local sn = data.statename
      local rod = self:GetRod()
      if rod then
         local fishingrodcomp = rod.components.fishingrod

         if sn == "fishing_nibble" and not fishingrodcomp:HasHookedFish() then
            -- fish nibbles
            local pAction = BufferedAction(self.inst, self.target, ACTIONS.REEL, self:GetRod(), nil, nil, FISHING_REEL_DIST)
            pAction:AddFailAction(function() self:OnFail() end)
            self.action = pAction
            inst.components.locomotor:PushAction(pAction, true)

         elseif sn == "fishing_strain" and not fishingrodcomp.caughtfish then
            -- fish hooked
            local pAction = BufferedAction(self.inst, self.target, ACTIONS.REEL, self:GetRod(), nil, nil, FISHING_REEL_DIST)
            pAction:AddFailAction(function() self:OnFail() end)
            self.action = pAction
            inst.components.locomotor:PushAction(pAction, true)
         end
      end
   end

   -- reel if state switches and is fishing related. best way by far
   self.inst:ListenForEvent('newstate', self.reel)
   -- fishing collect is pushed when finish fishing, only this means SUCCESS
   self.inst:ListenForEvent('fishingcollect', function ()
      self.status = SUCCESS
   end)
end)

function PerformFishing:OnFail()
   error('\nfail to fish\n')
   self.pendingstatus = FAILED
end
function PerformFishing:OnSucceed()
   error('\nsuccesffuly fished\n')
   self.status = SUCCESS
end

---
-- Get the fishing rod being used by character
-- @return the fishing rod instance
function PerformFishing:GetRod()
   -- get in equip first, usually there.
   local inv = self.inst.components.inventory
   if inv then
      local equippedinhand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
      if equippedinhand and equippedinhand.prefab == 'fishingrod' then
         return equippedinhand
      end

      -- else get from inventory, GOAP makes sure its there
      local rodininv = inv:FindItem(function (item)
         -- equipt it (need implementing)
         return item.prefab == 'fishingrod'
      end)
   end
end

---
-- Behaviour for fishing, only starts the fishing process.
-- Uses Buffered action with ACTIONS.FISH as with player fishing, but not coupled
-- @see generalutils/gameutils.GetClosesetInstOf
function PerformFishing:Visit()

   if self.status == READY then

      self.target = GetClosestInstOf('pond', self.inst, SIGHT_DISTANCE) -- only fish in pond

      if self.target then
         local pAction = BufferedAction(self.inst, self.target, ACTIONS.FISH, self:GetRod(), nil, nil, FISHING_DIST)
         pAction:AddFailAction(function() self:OnFail() end)
         self.action = pAction
         self.pendingstatus = nil
         -- push action to locomotor, DS system handles
         self.inst.components.locomotor:PushAction(pAction, true)
         self.status = RUNNING
      else
         self.status = FAILED
      end
   elseif self.status == RUNNING then

      if self.pendingstatus then
         self.status = self.pendingstatus
      elseif not self.action:IsValid() then
         self.status = FAILED
      end
   end
end