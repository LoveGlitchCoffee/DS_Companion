require("goals/goal")
require("general-utils/config")

FollowPlayer = Class(Goal, function(self, inst, player)
   Goal._ctor(self, inst, "FollowPlayer")
   self.urgency = FOLLOW_PLAYER_U
   self.player = player
end)

function FollowPlayer:OnStop()
end

function FollowPlayer:Satisfaction()
   -- further away, need to follow more
   -- if doing task, could reduce satisfaction
   local pos = Point(self.inst.Transform:GetWorldPosition())
   local target_pos = Point(self.player.Transform:GetWorldPosition())
   local dist_sq = distsq(pos, target_pos)

   -- closer we are the more satisfied we are
   local satisfaction = 1 - (dist_sq / (FOLLOW_OUT_OF_REACH * FOLLOW_OUT_OF_REACH))
   if satisfaction < 0 then -- super far away
      return 0
   end
   return satisfaction
end

function FollowPlayer:GetGoalState()
   return {close_to_player=true}
end