require "goals/goal"
require "generalutils/config"

---
-- Goal of following player
-- @param inst Instance to follow player
-- @param player player to follow
-- @class FollowPlayer
FollowPlayer = Class(Goal, function(self, inst, player)
   Goal._ctor(self, inst, "FollowPlayer")
   self.urgency = FOLLOW_PLAYER_U
   self.player = player
end)

function FollowPlayer:OnStop()
end

---
-- Satisfaction of following player is defined as how close the character is
-- to the player.
-- The goal is more satisfied the closer the character is to the player.
-- @return satisfaction of the goal
function FollowPlayer:Satisfaction()
   -- further away, need to follow more
   -- if doing task, could reduce satisfaction
   local pos = Point(self.inst.Transform:GetWorldPosition())
   local target_pos = Point(self.player.Transform:GetWorldPosition())
   local dist_sq = distsq(pos, target_pos)

   -- closer we are the more satisfied we are
   local satisfaction = 1 - (dist_sq / (FOLLOW_OUT_OF_REACH * FOLLOW_OUT_OF_REACH * INDEPENDENCE_SCALE))
   if satisfaction < 0 then -- super far away
      return 0 -- no satisfaction
   end
   return satisfaction
end

---
-- returns STRIPS goal precondition for planning
-- @return close_to_player precondition as table
function FollowPlayer:GetGoalState()
   return {close_to_player=true}
end