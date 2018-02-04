require("general-utils/gameutils")

PerformFishing = Class(BehaviourNode, function(self, inst)
   BehaviourNode._ctor(self, "PerformFishing")
   self.inst = inst   
   self.fishhooked = false

   self.reel = function (inst, data)
      local sn = data.statename      
      local fishingrodcomp = self:GetRod().components.fishingrod
      if sn == "fishing_nibble" and not fishingrodcomp:HasHookedFish() then
         error("HOOK")         
         local pAction = BufferedAction(self.inst, self.target, ACTIONS.REEL, self:GetRod(), nil, nil, 0.7)
         pAction:AddFailAction(function() self:OnFail() end)
         self.action = pAction         
         inst.components.locomotor:PushAction(pAction, true)
      elseif sn == "fishing_strain" and not fishingrodcomp.caughtfish then
         error("REELING")
         self.fishhooked = true
         local pAction = BufferedAction(self.inst, self.target, ACTIONS.REEL, self:GetRod(), nil, nil, 0.7)
         pAction:AddFailAction(function() self:OnFail() end)
         pAction:AddSuccessAction(function() self:OnFail() end)
         self.action = pAction         
         inst.components.locomotor:PushAction(pAction, true)
      --else
      end         
      -- only occur if in those states above
   end

   self.inst:ListenForEvent('newstate', self.reel)
end)

function PerformFishing:OnFail()
   error('\nfail to fish\n')
   self.pendingstatus = FAILED
end
function PerformFishing:OnSucceed()
   error('\nsuccesffuly fished\n')
   self.pendingstatus = SUCCESS
end

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
         -- equipt it
         return item.prefab == 'fishingrod'
      end)
   end
end

function PerformFishing:Visit()
   if self.status == READY then
      self.target = GetClosestInstOf('pond', self.inst, 7)
      if self.target then
         error('found pond')
         local pAction = BufferedAction(self.inst, self.target, ACTIONS.FISH, self:GetRod(), nil, nil, 3.5)
         pAction:AddFailAction(function() self:OnFail() end)
         self.action = pAction
         self.pendingstatus = nil
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