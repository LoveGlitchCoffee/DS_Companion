require "generalutils/debugprint"
require "generalutils/gameutils"
require "generalutils/config"

---
-- Custom behaviour that replaces default Wander behaviour when following player
-- @param inst Instance to do the wandering
-- @class WalkRandomly
WalkRandomly = Class(BehaviourNode, function(self, inst, player)
   BehaviourNode._ctor(self, "WalkRandomly")
   self.inst = inst
   self.timeout = 0
   self.player = player

   self.inst.components.locomotor:SetReachDestinationCallback(
      function()         
         error("reached")
         self.inst.components.locomotor:Stop()         
      end)
end)

function WalkRandomly:OnFail()
   self.pendingstatus = FAILED
end
function WalkRandomly:OnSucceed()
   self.pendingstatus = SUCCESS
end

---
-- Visit chooses a random point within the targeted distance to player
-- to walk to.
-- also sets a timeout walking in that direction.
-- Sleeps until timeout then stops locomoting
function WalkRandomly:Visit()
   if self.status == READY then

      self.timeout = GetTime() + WAIT_TIME
      -- error('current pos '..tostring(self.inst:GetPosition()))
      self.newpos = GenerateRandomValidPointWithRadius(self.player:GetPosition(), FOLLOW_CLOSE_DIST, FOLLOW_TARGET_DIST)
      -- error('got new pos fine '..tostring(self.newpos))      
      self.status = RUNNING

   elseif self.status == RUNNING then
      --error('time now: '..tostring(GetTime()))
      --error('end time: '..tostring(self.timeout))

      self.inst.components.locomotor:GoToPoint(self.newpos, nil, true) -- can't do walk for now cuz no SG
         
      if GetTime() > self.timeout then
         self.inst.components.locomotor:Stop()         
         self.status = SUCCESS
         return
      end

      self:Sleep(self.timeout - GetTime()) -- sleep until timeout
   end
end