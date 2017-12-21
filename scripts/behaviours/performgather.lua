require 'general-utils/gameutils'

PerformGather = Class(BehaviourNode, function(self, inst, item)
   BehaviourNode._ctor(self, "PerformGather")
   self.inst = inst
   self.item = item
   self.action = nil

   self.locomotorFailed = function(inst, data)
		local theAction = data.action or "[Unknown]"
		local theReason = data.reason or "[Unknown]"
		print("\nPerformGather: Action: " .. theAction:__tostring() .. " failed. Reason: " .. tostring(theReason) .. '\n')
		self:OnFail()
   end

   self.inst:ListenForEvent("actionfailed", self.locomotorFailed)
end)

function PerformGather:OnFail()
   warning('\nfail to pick up\n')
   self.pendingstatus = FAILED
end
function PerformGather:OnSucceed()
   warning('\nsuccesffuly picked up\n')
   self.pendingstatus = SUCCESS
end

function PerformGather:Visit()   
   -- body
   if self.status == READY then

      local target = FindEntity(self.inst, 4, function(resource)         
         if resource.components.pickable then
            warning('FOUND THIS: ' .. tostring(resource.components.pickable.product))
            warning('finding: ' .. self.item .. '\n')
         end
         return resource.components.pickable
         and resource.components.pickable.product == self.item
         and resource.components.pickable:CanBePicked()
         and resource.components.pickable.caninteractwith
      end)

      warning('target: ' .. tostring(target))

      if target then
         local pAction = BufferedAction(self.inst, target, ACTIONS.PICK)
         pAction:AddFailAction(function() self:OnFail() end)
         pAction:AddSuccessAction(function() self:OnSucceed() end)         
         self.action = pAction
         self.pendingstatus = nil
         self.inst.components.locomotor:PushAction(pAction, true)
         self.status = RUNNING
      else                  
         self.status = FAILED -- can't find anything then fail
      end      
   elseif self.status == RUNNING then
      if self.pendingstatus then
         self.status = self.pendingstatus
         warning('\nkeep running\n')
      elseif not self.action:IsValid() then
         warning('\nfail as action not valid\n')
         self.status = FAILED
      end
   end
end