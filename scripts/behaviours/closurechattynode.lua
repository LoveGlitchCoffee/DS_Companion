ClosureChattyNode = Class(BehaviourNode, function(self, inst, chatlines, time)
      BehaviourNode._ctor(self, "ClosureChattyNode")

      self.inst = inst
      self.chatlines = chatlines
      self.time = time

      self.finishtalking = function (inst, data)
         self.status = SUCCESS
      end

      self.inst:ListenForEvent('donetalking', self.finishtalking)
      
end)

function ClosureChattyNode:OnStop()
   self.inst:RemoveEventCallback('donetalking', self.finishtalking)
end

function ClosureChattyNode:Visit()
   if self.status == READY then
      local t = GetTime()

      if not self.nextchattime or t > self.nextchattime then
         local str = self.chatlines[math.random(#self.chatlines)]
         self.inst.components.talker:Say(str, self.time)
      end

      self.status = RUNNING
   end
end
