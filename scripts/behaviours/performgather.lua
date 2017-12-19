require 'general-utils/gameutils'

PerformGather = Class(BehaviourNode, function(self, inst, item)
   BehaviourNode._ctor(self, "PerformGather")
   self.inst = inst
   self.item = item
end)

function PerformGather:OnFail()
   self.pendingstatus = FAILED
end
function PerformGather:OnSucceed()
   self.pendingstatus = SUCCESS
end

function PerformGather:Visit()   
   -- body
   if self.status == READY then

      local target = FindEntity(self.inst, 4, function(resource)
         return resource.components.pickable
         and resource.components.pickable.product.prefab == self.item
      end)

      if target then
         local pAction = BufferedAction(self.inst, target, ACTIONS.PICK)
         pAction:AddFailAction(function() self:OnFail() end)
			   pAction:AddSuccessAction(function() self:OnSucceed() end)
			   self.action = pAction
			   self.pendingstatus = nil
			   self.inst.components.locomotor:PushAction(pAction, true)
			   self.status = RUNNING
      end
      self.status = FAILED -- can't find anything then fail
   elseif self.status == RUNNING then
      if self.pendingstatus then
         self.status = self.pendingstatus
      elseif not self.action:IsValid() then
         self.status = FAILED
      end
   end
end