require 'actions/action'
require 'behaviours/follow'
require 'behaviours/walkrandomly'
require 'general-utils/debugprint'
require 'general-utils/table_ops'
require("general-utils/config")
require("behaviours/chattynode")

FollowPlayerAction = Class(Action, function (self, inst, player)
   Action._ctor(self, inst, 'FollowPlayerAction')
   self.player = player
   self.reason = ""
   self.addreasontochatlines = function (inst, data)
      error("GOT REASON "..tostring(data.reason))
      self.reason = data.reason
   end

   self.inst:ListenForEvent('failreasoning', self.addreasontochatlines)
end)

function FollowPlayerAction:Precondition()
   return {}
end

function FollowPlayerAction:PostEffect()
   return {close_to_player=true}
end

function FollowPlayerAction:Cost()
   return 0 -- only action to follow. this is goal adjustable
end

function FollowPlayerAction:Perform()
   local pos = Point(self.inst.Transform:GetWorldPosition())
   local target_pos = Point(self.player.Transform:GetWorldPosition())
   local dist_sq = distsq(pos, target_pos)
   
   warning('DISTANCE: '..tostring(dist_sq))
   if dist_sq < FOLLOW_TARGET_DIST * FOLLOW_TARGET_DIST then
      warning('WANDER')
      -- very close to player
      return ChattyNode(self.inst, {"WEATHER: HABITABLE", "", "",self.reason}, WalkRandomly(self.inst))

   elseif dist_sq > FOLLOW_TARGET_DIST * FOLLOW_TARGET_DIST   
   and dist_sq < FOLLOW_OUT_OF_REACH * FOLLOW_OUT_OF_REACH then
      warning('follow slowting')
      return Follow(self.inst, self.player, FOLLOW_CLOSE_DIST, FOLLOW_TARGET_DIST, FOLLOW_FAR_DIST, true) -- want to be false but no SG for now

   elseif dist_sq > FOLLOW_OUT_OF_REACH * FOLLOW_OUT_OF_REACH then
      warning('follow quickly')
      return ChattyNode(self.inst, {"OWNER, PLEASE WAIT"}, Follow(self.inst, self.player, FOLLOW_CLOSE_DIST, FOLLOW_TARGET_DIST, FOLLOW_FAR_DIST, true))
   end
end