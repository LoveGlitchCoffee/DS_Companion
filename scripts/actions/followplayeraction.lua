require 'actions/action'
require 'behaviours/follow'
require 'behaviours/walkrandomly'
require 'general-utils/debugprint'
require 'general-utils/table_ops'

FollowPlayerAction = Class(Action, function (self, inst, player)   
   Action._ctor(self, inst, 'FollowPlayerAction')
   self.player = player   
   self.TARGET_DIST = 6
   self.FAR_DIST = 10
end)

function FollowPlayerAction:Precondition()
   return {}
end

function FollowPlayerAction:PostEffect()      
   return {close_to_player=true}
end

function FollowPlayerAction:Cost()
   return 2
end

function FollowPlayerAction:Perform()
   local pos = Point(self.inst.Transform:GetWorldPosition())
   local target_pos = Point(self.player.Transform:GetWorldPosition())
   local dist_sq = distsq(pos, target_pos)

   --if dist_sq < self.CLOSE_DIST*self.CLOSE_DIST then
   --   warning('WANDER INTEAD')
   --   return Wander(self.inst, target_pos, 5, {minwalktime=2, randwalktime=2.5, minwaittime=0, randwaittime=0.5})
   --end
   warning('DISTANCE: '..tostring(dist_sq))
   if dist_sq < self.TARGET_DIST*self.TARGET_DIST then
      warning('WANDER')
      -- very close to player
      return WalkRandomly(self.inst)
   elseif dist_sq > self.TARGET_DIST*self.TARGET_DIST 
   and dist_sq < self.FAR_DIST*self.FAR_DIST then
      warning('follow slowting')
      return Follow(self.inst, self.player, 4, 6, 8, true) -- want to be false but no SG for now
   elseif dist_sq > self.FAR_DIST * self.FAR_DIST then
      warning('follow quickly')
      return Follow(self.inst, self.player, 5, 6, 8, true)
   else
      
   end
end