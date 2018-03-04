require "actions/action"
require "generalutils/debugprint"
require "generalutils/table_ops"
require "generalutils/config"
require "behaviours/performstayput"
require "generalutils/gameutils"

---
-- STRIPS action for not following player into danger
-- @param inst Instance of companion following player
-- @param player Player Instance
-- @class StayPut
StayPut = Class(Action, function (self, inst)
   Action._ctor(self, inst, 'StayPut')   
end)

---
-- No preconditions for following player
-- @return empty precondition table
function StayPut:Precondition()
   return {}
end

---
-- Effect of following player is being close to player
-- @return effect of being close to player as STRIPS post effect
function StayPut:PostEffect()
   return {close_to_player=true}
end

---
-- No precieved cost of following player.
-- Could be improved with danger level around player,
-- but current onyl action to satisfy that goal so no meaningful advantage.
-- @return No cost
function StayPut:PreceivedCost()   
   info("staying put cost "..tostring(CheckDangerLevel(Point(self.inst.Transform:GetWorldPosition()))))
   return CheckDangerLevel(Point(self.inst.Transform:GetWorldPosition())) -- only action to follow. this is goal adjustable
end

---
-- Perform of staying put due to dangerg
function StayPut:Perform()
   return PerformStayPut(self.inst)
end