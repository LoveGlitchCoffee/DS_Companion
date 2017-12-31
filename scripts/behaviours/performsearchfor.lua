require 'general-utils/debugprint'

PerformSearchFor = Class(BehaviourNode, function(self, inst, item)
   -- search for is travelling in a random direction
   -- then do another check to see if item wanted is in view
   -- fail if no item is in view then
   BehaviourNode._ctor(self, "PerformSearchFor")
   self.inst = inst
   self.item = item
   self.waittime = 0
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
      local maxSearchDist = 20
      local minSearchDist = 5
      local currentPos = Vector3(self.inst.Transform:GetWorldPosition())
      local newx = currentPos.x + math.rad(minSearchDist, maxSearchDist)
      local newy = currentPos.y + math.rad(minSearchDist, maxSearchDist)
      local newPos = Vector3(newx, newy, currentPos.z)
      -- implement valid point later
      action =  BufferedAction(self.inst, nil, ACTIONS.WALKTO, nil, newPos,nil, 0.1)
      action:AddFailAction(function() self:OnFail() end)
      action:AddSuccessAction(function() self:OnSucceed() end)   
      self.action = action
      self.pendingstatus = nil   
      self.inst.components.locomotor:PushAction(action, true)   
      self.status = RUNNING
   elseif self.status == RUNNING then
      if self.pendingstatus then
         self.status = self.pendingstatus
      elseif not self.action:IsValid() then
         self.status = FAILED
      end   
   end
end

function PerformSearchFor:SearchWithDirection()
   if self.status == READY then      
      info('searching for food now')
      local randomAngle = math.random() * 360 -- in degrees
      error('random degrees ' .. tostring(randomAngle))
      self.waittime = GetTime() + 100
      error('start time '..tostring(GetTime()))
      error('end time '..tostring(self.waittime))
      self.inst.components.locomotor:WalkInDirection(randomAngle)
      self.status = RUNNING
   elseif self.status == RUNNING then
      error('time '..tostring(GetTime()))      
      if GetTime() > self.waittime then
         error('finish searching. look around')
         local target = FindEntity(self.inst, 4, function(resource)
            if resource.components.pickable then -- might want to change at some point
               return resource.components.pickable.product == self.item
            else
               return resource.prefab == self.item
            end            
         end)

         if target then
            -- found something after searching
            self.status = SUCCESS
         else
            self.status = FAILED -- for now only try once            
         end
         self.inst.components.locomotor:Stop() -- later change so only stop when completely fail and success         
      end

      self:Sleep(self.waittime - GetTime()) -- sleep until wake
   end
end

function PerformSearchFor:Visit()
   self:SearchWithDirection()
end