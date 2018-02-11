require "generalutils/debugprint"

---
-- Custom behaviour that replaces default Wander behaviour when following player
-- @param inst Instance to do the wandering
-- @class WalkRandomly
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

---
-- Visit chooses a random angle to walk towards
-- also sets a timeout walking in that direction
-- Sleeps until timeout then stops locomoting
function WalkRandomly:Visit()
   if self.status == READY then
      local randomAngle = math.random() * 360 -- in degrees
      self.waittime = GetTime() + 2
      self.inst.components.locomotor:RunInDirection(randomAngle) -- can't do walk for now cuz no SG
      self.status = RUNNING

   elseif self.status == RUNNING then
      --error('time now: '..tostring(GetTime()))
      --error('end time: '..tostring(self.waittime))

      if GetTime() > self.waittime then      
         self.inst.components.locomotor:Stop()
         -- could do a wait before succeed, look more natural
         self.status = SUCCESS
         return
      end

      self:Sleep(self.waittime - GetTime()) -- sleep until timeout
   end
end