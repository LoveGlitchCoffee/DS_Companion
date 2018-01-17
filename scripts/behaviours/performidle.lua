require 'general-utils/debugprint'

PerformIdle = Class(BehaviourNode, function(self)
   BehaviourNode._ctor(self, "PerformIdle")   
end)

function PerformIdle:Visit()
   if self.status == READY then      
      self.status = SUCCESS
      return
   end
end