require "behaviours/chattynode"
require "behaviours/standstill"

PerformStayPut = Class(BehaviourNode, function (self, inst)
   BehaviourNode._ctor(self, "StayPut")
   self.inst = inst
end)

function PerformStayPut:Visit( )
   if self.status == READY then
      self.startime = GetTime()
      self.runner = ChattyNode(self.inst, {"Staying out of danger"}, StandStill(self.inst, nil, function (inst)
         return GetTime() < self.startime + 5
      end))
      self.status = RUNNING

   elseif self.status == RUNNING then
      self.runner:Visit()
      self.status = self.runner.status
   end
end