require("general-utils/gameutils")
require("general-utils/config")

PerformFishing = Class(BehaviourNode, function(self, inst)
   BehaviourNode._ctor(self, "PerformFishing")
   self.inst = inst   

   self.reel = function (inst, data)
      local sn = data.statename      
      local fishingrodcomp = self:GetRod().components.fishingrod
      if sn == "fishing_nibble" and not fishingrodcomp:HasHookedFish() then         
         local pAction = BufferedAction(self.inst, self.target, ACTIONS.REEL, self:GetRod(), nil, nil, FISHING_DIST)
         pAction:AddFailAction(function() self:OnFail() end)
         self.action = pAction         
         inst.components.locomotor:PushAction(pAction, true)
      elseif sn == "fishing_strain" and not fishingrodcomp.caughtfish then                  
         local pAction = BufferedAction(self.inst, self.target, ACTIONS.REEL, self:GetRod(), nil, nil, FISHING_DIST)
         pAction:AddFailAction(function() self:OnFail() end)
         pAction:AddSuccessAction(function() self:OnSucceed() end)
         self.action = pAction         
         inst.components.locomotor:PushAction(pAction, true)         
      end               
   end

   self.inst:ListenForEvent('newstate', self.reel)
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
      self.target = GetClosestInstOf('pond', self.inst, SIGHT_DISTANCE)
      if self.target then         
         local pAction = BufferedAction(self.inst, self.target, ACTIONS.FISH, self:GetRod(), nil, nil, DEFAULT_DISTANCE)
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
         error("pending "..tostring(self.pending))
         self.status = self.pendingstatus
      elseif not self.action:IsValid() then
         self.status = FAILED
      end
   end
end