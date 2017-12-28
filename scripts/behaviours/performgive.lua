PerformGive = Class(BehaviourNode, function(self, inst, item, target)
   BehaviourNode._ctor(self, "PerformGive")
   self.inst = inst
   self.item = item
   self.target = target
end)

function PerformGive:OnFail()
   warning('\nfail to pick up\n')
   self.pendingstatus = FAILED
end
function PerformGive:OnSucceed()
   warning('\nsuccesffuly picked up\n')
   self.pendingstatus = SUCCESS
end

function PerformGive:Visit()   
   if self.status == READY then
      error('giving to '..tostring(self.target))
      
   end      
end