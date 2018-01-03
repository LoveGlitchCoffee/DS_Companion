require 'general-utils/debugprint'

WalkRandomly = Class(BehaviourNode, function(self, inst)   
   BehaviourNode._ctor(self, "WalkRandomly")
   self.inst = inst   
   self.waittime = 0
end)

function WalkRandomly:OnFail()
   self.pendingstatus = FAILED
end
function WalkRandomly:OnSucceed()
   self.pendingstatus = SUCCESS
end

function WalkRandomly:Visit()
   if self.status == READY then      
      error('READY NOW')
      local randomAngle = math.random() * 360 -- in degrees      
      self.waittime = GetTime() + 2
      self.inst.components.locomotor:WalkInDirection(randomAngle)
      self.status = RUNNING
   elseif self.status == RUNNING then
      error('time now: '..tostring(GetTime()))
      error('end time: '..tostring(self.waittime))
      if GetTime() > self.waittime then
         error('success')
         self.inst.components.locomotor:Stop() -- later change so only stop when completely fail and success
         self.status = SUCCESS
         return
      end
      self:Sleep(self.waittime - GetTime()) -- sleep until wake
   end
end