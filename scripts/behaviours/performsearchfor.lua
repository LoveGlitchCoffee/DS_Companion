require "generalutils/debugprint"

---
-- Custom behaviour for searching for item or entity,
-- if item is being searched it is item that can be picked up, not resource
-- @param inst Instance to do the searching
-- @param entity Entity to search for, could be other characters in addition to items
-- @param period period to do evaluation of checking if desired entity is near
-- @param newpos position of where to go to for searching
-- @class PerformSearchFor
PerformSearchFor = Class(BehaviourNode, function(self, inst, entity, period, newpos)
   BehaviourNode._ctor(self, "PerformSearchFor")
   self.inst = inst
   self.entity = entity
   self.period = period
   self.newpos = newpos

   -- when reach destination do a check if desired item is in view
   -- set state according to whether if item is in view
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

---
-- Search by going to a point and check along the way if desired entity is in view
-- Check interval depends on self.period.
-- @see actions.searchfor
function PerformSearchFor:SearchWithPoint()
   if self.status == READY then
      if self.newpos then
         -- timeout after 5 seconds because behaviour is bugging on valid point
         self.timeout = GetTime() + 7
         self.inst.components.locomotor:GoToPoint(self.newpos, nil, true)
         self.lasttime = GetTime()

         -- initial test, if target already in view then found
         if self:CheckTarget() then
            self.status = SUCCESS
         else
            self.status = RUNNING
         end

      else
         -- fail if no valid point was generated initally from STRIPS action
         self.status = FAILED
      end

   elseif self.status == RUNNING then
      -- evaluate every interval
      local eval = self.lasttime and self.period and GetTime() > self.lasttime + self.period
      if eval then
         -- checks to see if entity in sight
         local target = self:CheckTarget()
         self.lasttime = GetTime()
         if target then
            info("found someething stop locomoting")
            -- found something after searching
            self.status = SUCCESS
            self.inst.components.locomotor:Stop()
         end
      end

      -- time out then failed
      if GetTime() > self.timeout then
         info("timed out")
         self.status = FAILED
         self.inst.components.locomotor:Stop()
      end
   end
end

---
-- Checks if target is in sight, uses FindEntity
function PerformSearchFor:CheckTarget()
   return FindEntity(self.inst, SIGHT_DISTANCE,
      function(ent)
         return ent.prefab == self.entity
      end)
end

-- Visit calls SearchWithPoint,
-- seperated for easy sub with other searching methods
-- @see SearchWithPoint
function PerformSearchFor:Visit()
   self:SearchWithPoint()
end
