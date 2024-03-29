require "generalutils/gameutils"

---
-- Custom behaviour for gathering items in world
-- @param inst Instance to do the gathering
-- @param item Item to gather
-- @class PerformGather
PerformGather = Class(BehaviourNode, function(self, inst, item)
   BehaviourNode._ctor(self, "PerformGather")
   self.inst = inst
   self.item = item
   self.action = nil

   -- state reason for failure if fail behaviour
   self.locomotorFailed = function(inst, data)
      local theAction = data.action or "[Unknown]"
      local theReason = data.reason or "[Unknown]"
      print(
         "\nPerformGather: Action: " .. theAction:__tostring() .. " failed. Reason: " .. tostring(theReason) .. "\n"
      )
      self:OnFail()
   end
   self.inst:ListenForEvent("actionfailed", self.locomotorFailed)
end)

function PerformGather:OnStop()
   self.inst:RemoveEventCallback("actionfailed", self.locomotorFailed)
end

function PerformGather:OnFail()
   warning("\nfail to pick up\n")
   self.pendingstatus = FAILED
end
function PerformGather:OnSucceed()
   warning("\nsuccesffuly picked up\n")
   self.pendingstatus = SUCCESS
end

---
-- Find the item within certain radius, should be available due to previous searching action.
-- If item is a resource then use ACTIONS.PICK in BufferedAction
-- otherwise use ACTIONS.PICKUP as on ground.
function PerformGather:Visit()
   if self.status == READY then

      -- find the target resource that can be picked
      local target =
         FindEntity(self.inst, SIGHT_DISTANCE,
         function(resource)
            if resource.components.pickable then
               warning("FOUND THIS: " .. tostring(resource.components.pickable.product))
               warning("finding: " .. self.item .. "\n")
            end            
            return resource.components.pickable and resource.components.pickable.product == self.item and
               resource.components.pickable:CanBePicked() and
               resource.components.pickable.caninteractwith
         end
      )

      warning("target: " .. tostring(target))

      -- found item and can harvest it
      if target then
         local pAction = BufferedAction(self.inst, target, ACTIONS.PICK)
         pAction:AddFailAction(function() self:OnFail() end)
         pAction:AddSuccessAction(function() self:OnSucceed() end)
         self.action = pAction
         self.pendingstatus = nil
         self.inst.components.locomotor:PushAction(pAction, true)
         self.status = RUNNING
      else
         -- no target that can be picked so pickup instead
         target =
            FindEntity(self.inst, SIGHT_DISTANCE,
            function(item)
               return item.prefab == self.item
            end
         )

         if target and target.components.inventoryitem
            and target.components.inventoryitem.canbepickedup
            and target:IsOnValidGround()
            and not target.components.inventoryitem:IsHeld()
         then
            error("found " .. tostring(target))
            local pAction = BufferedAction(self.inst, target, ACTIONS.PICKUP)
            pAction:AddFailAction(function() self:OnFail() end)
            pAction:AddSuccessAction(function() self:OnSucceed() end)
            self.action = pAction
            self.pendingstatus = nil
            self.inst.components.locomotor:PushAction(pAction, true)
            self.status = RUNNING
         else
            error('FAILED')
            self.status = FAILED
         end
      end
   elseif self.status == RUNNING then
      if self.pendingstatus then
         self.status = self.pendingstatus
         warning("\nkeep running\n")
      elseif not self.action:IsValid() then
         warning("\nfail as action not valid\n")
         self.status = FAILED
      end
   end
end
