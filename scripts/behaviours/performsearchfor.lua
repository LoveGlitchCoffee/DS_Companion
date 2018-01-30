require "general-utils/debugprint"

PerformSearchFor =
   Class(
   BehaviourNode,
   function(self, inst, entity, period, newPos)
      -- search for is travelling in a random direction
      -- then do another check to see if entity wanted is in view
      -- fail if no entity is in view then
      BehaviourNode._ctor(self, "PerformSearchFor")
      self.inst = inst
      self.entity = entity
      self.period = period
      self.newPos = newPos

      self.inst.components.locomotor:SetReachDestinationCallback(function ()
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

-- unused atm
function PerformSearchFor:SearchWithPoint()
   if self.status == READY then
      if self.newPos then
         self.timeout = GetTime() + 5
         self.inst.components.locomotor:GoToPoint(self.newPos, nil, true)
         self.lasttime = GetTime()
         self.status = RUNNING
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
   return FindEntity(
      self.inst,
      6,
      function(ent)
         return ent.prefab == self.entity
      end
   )
end

function PerformSearchFor:SearchWithDirection()
   if self.status == READY then
      local randomAngle = math.random() * 360 -- in degrees
      info("random degrees " .. tostring(randomAngle))
      self.waittime = GetTime() + 2 -- originally 6
      self.lasttime = GetTime()
      info("start time " .. tostring(GetTime()))
      info("end time " .. tostring(self.waittime))
      self.inst.components.locomotor:RunInDirection(randomAngle) -- want walk but not SG
      self.status = RUNNING
   elseif self.status == RUNNING then
      info("time " .. tostring(GetTime()))
      local eval = self.lasttime and self.period and GetTime() > self.lasttime + self.period
      if GetTime() > self.waittime or eval then
         local target = self:CheckTarget()
         self.lasttime = GetTime()

         if target then -- regarldess of eval
            -- found something after searching
            self.status = SUCCESS
            self.inst.components.locomotor:Stop()
         elseif not eval then -- and not target
            info("complete search found nothing")
            self.status = FAILED -- for now only try once
            self.inst.components.locomotor:Stop() -- later change so only stop when completely fail and success
         end
      end

      self:Sleep(self.waittime - GetTime()) -- sleep until wake
   end
end

function PerformSearchFor:Visit()
   self:SearchWithPoint()
end
