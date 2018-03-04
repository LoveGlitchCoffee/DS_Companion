require "actions/action"
require "behaviours/follow"
require "behaviours/walkrandomly"
require "generalutils/debugprint"
require "generalutils/table_ops"
require "generalutils/config"
require "behaviours/chattynode"
require "generalutils/gameutils"

---
-- STRIPS action for following player
-- @param inst Instance of companion following player
-- @param player Player Instance
-- @class FollowPlayerAction
FollowPlayerAction = Class(Action, function (self, inst, player)
   Action._ctor(self, inst, 'FollowPlayerAction')
   self.player = player
   self.reason = ""

   -- whilst following player, can talk about previously failed action
   self.addreasontochatlines = function (inst, data)
      info("GOT REASON "..tostring(data.reason))
      self.reason = data.reason
   end

   self.inst:ListenForEvent('failreasoning', self.addreasontochatlines)
end)

---
-- No preconditions for following player
-- @return empty precondition table
function FollowPlayerAction:Precondition()
   return {}
end

---
-- Effect of following player is being close to player
-- @return effect of being close to player as STRIPS post effect
function FollowPlayerAction:PostEffect()
   return {close_to_player=true}
end

---
-- No precieved cost of following player.
-- Could be improved with danger level around player,
-- but current onyl action to satisfy that goal so no meaningful advantage.
-- @return No cost
function FollowPlayerAction:PreceivedCost()   
   info("follow cost "..tostring(CheckDangerLevel(Point(self.player.Transform:GetWorldPosition()))))
   return CheckDangerLevel(Point(self.player.Transform:GetWorldPosition())) -- only action to follow. this is goal adjustable
end

---
-- Perform of following player uses custom Wander Behaviour and Follow Behaviour.
-- Custom Wander, known as WalkRandomly returned when close to player, otherwise Follow is used.
-- WalkRandomly is used because more control over how to wander.
-- Return behaviours be wrapped around a ChattyNode to do some talking.
-- @return WalkRandomly Behaviour or Follow Behaviour depending on distance to player
-- @see behaviours/walkrandomly.WalkRandomly
function FollowPlayerAction:Perform()

   -- Get the distance
   local pos = Point(self.inst.Transform:GetWorldPosition())
   local target_pos = Point(self.player.Transform:GetWorldPosition())
   local dist_sq = distsq(pos, target_pos)

   info('DISTANCE: '..tostring(dist_sq))
   if dist_sq <= FOLLOW_TARGET_DIST * FOLLOW_TARGET_DIST then
      info('WANDER')
      -- very close to player
      return ChattyNode(self.inst, {"WEATHER: HABITABLE", "", "",self.reason}, WalkRandomly(self.inst, self.player))

   elseif dist_sq > FOLLOW_TARGET_DIST * FOLLOW_TARGET_DIST
   and dist_sq <= FOLLOW_OUT_OF_REACH * FOLLOW_OUT_OF_REACH then
      info('follow slowly')
      -- close-ish but should follow
      return Follow(self.inst, self.player, FOLLOW_CLOSE_DIST, FOLLOW_TARGET_DIST, FOLLOW_FAR_DIST, true) -- want to be walk but no anim

   elseif dist_sq > FOLLOW_OUT_OF_REACH * FOLLOW_OUT_OF_REACH then
      info('follow quickly')
      -- far away so run
      return ChattyNode(self.inst, {"CREATOR, PLEASE WAIT"}, Follow(self.inst, self.player, FOLLOW_CLOSE_DIST, FOLLOW_TARGET_DIST, FOLLOW_FAR_DIST, true))
   else
      info("STUCK")
   end
end