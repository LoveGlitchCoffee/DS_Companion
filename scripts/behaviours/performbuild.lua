require 'general-utils/gameutils'

PerformBuild = Class(BehaviourNode, function(self, inst, item)
   BehaviourNode._ctor(self, "PerformBuild")
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

function PerformBuild:OnStop()
   self.inst:RemoveEventCallback("actionfailed", self.locomotorFailed)
end

function PerformBuild:OnFail()   
   self.pendingstatus = FAILED
end
function PerformBuild:OnSucceed()   
   self.pendingstatus = SUCCESS
end

function PerformBuild:Visit()      
   if self.status == READY then
      
      
      warning('target: ' .. tostring(target))

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
         warning('\nkeep running\n')
      elseif not self.action:IsValid() then
         warning('\nfail as action not valid\n')
         self.status = FAILED
      end
   end
end