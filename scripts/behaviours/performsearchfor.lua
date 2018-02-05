require "general-utils/debugprint"

PerformSearchFor = Class(BehaviourNode, function(self, inst, entity, period, newPos)
   -- search for is travelling in a random direction
   -- then do another check to see if entity wanted is in view
   -- fail if no entity is in view then
   BehaviourNode._ctor(self, "PerformSearchFor")
   self.inst = inst
   self.entity = entity
   self.period = period
   self.newPos = newPos
   self.inst.components.locomotor:SetReachDestinationCallback(
      function()
         local target = self:CheckTarget()
         if target then
            -- found something after searching
            self.status = SUCCESS
         else
            self.status = FAILED
         end
      end)
end)

function PerformSearchFor:OnFail()
   self.pendingstatus = FAILED
end
function PerformSearchFor:OnSucceed()
   self.pendingstatus = SUCCESS
end

function PerformSearchFor:SearchWithPoint()
   if self.status == READY then
      if self.newPos then
         self.timeout = GetTime() + 5
         self.inst.components.locomotor:GoToPoint(self.newPos, nil, true)
         self.lasttime = GetTime()
         if self:CheckTarget() then
            self.status = SUCCESS
         else
            self.status = RUNNING
         end
      else
         self.status = FAILED
      end
   elseif self.status == RUNNING then
      local eval = self.lasttime and self.period and GetTime() > self.lasttime + self.period
      if eval then
         local target = self:CheckTarget()
         self.lasttime = GetTime()
         if target then -- regarldess of eval
            error("found someething stop locomoting")
            -- found something after searching
            self.status = SUCCESS
            self.inst.components.locomotor:Stop()
         end
      end
      if GetTime() > self.timeout then
         info("timed out")
         self.status = FAILED
         self.inst.components.locomotor:Stop()
      end
   end
end

function PerformSearchFor:CheckTarget()
   return FindEntity(self.inst, SIGHT_DISTANCE,
      function(ent)
         return ent.prefab == self.entity
      end)
end

function PerformSearchFor:Visit()
   self:SearchWithPoint()
end
