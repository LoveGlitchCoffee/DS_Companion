---
-- Custom behaviour for giving an item
-- @param inst Instance to do the giving
-- @param Item item to give as prefab name
-- @param target Target to give to, usually player
-- @class PerformGivin
PerformGive = Class(BehaviourNode, function(self, inst, item, target)
   BehaviourNode._ctor(self, "PerformGive")
   self.inst = inst
   self.item = item
   self.target = target
end)

function PerformGive:OnFail()
   error('\nfail to give\n')
   self.pendingstatus = FAILED
end

---
-- On success, push event to drop goal of giving item to player
-- Kinda wrong, should fix
function PerformGive:OnSucceed()
   error('\nsuccesffuly gave\n')
   self.pendingstatus = SUCCESS   
   self.inst:PushEvent('dropgoal', {goalname=('GetForPlayer'..self.item)})
end

---
-- Returns item instance from inventory.
-- @return item instance
function PerformGive:GetItemFromInventory()
   local item = nil
   if self.inst.components.inventory then
      item = self.inst.components.inventory:FindItem(function(invitem)
         return invitem.prefab == self.item
      end)
   end
   return item
end

---
-- Visit gets item from inventory then uses ACTIONS.GIVE
-- this is decoupled from player as opposed to original usage of ACTIONS.GIVE
-- @see GetItemFromInventory
function PerformGive:Visit()

   if self.status == READY then
      info('giving to '..tostring(self.target))

      if self.target then
         -- get item instance
         local item = self:GetItemFromInventory()
         
         if item then
            info('item found: '..tostring(item))
            local pAction = BufferedAction(self.inst, self.target, ACTIONS.GIVE, item, nil, nil, DEFAULT_DISTANCE)
            pAction:AddFailAction(function() self:OnFail() end)
            pAction:AddSuccessAction(function() self:OnSucceed() end)
            self.action = pAction
            self.pendingstatus = nil            
            self.inst.components.locomotor:PushAction(pAction, true)            
            self.status = RUNNING
         else
            self.status = FAILED
         end
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