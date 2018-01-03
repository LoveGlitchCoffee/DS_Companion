require 'actions/action'
require 'behaviours/follow'
require 'behaviours/walkrandomly'
require 'general-utils/debugprint'
require 'general-utils/table_ops'

FollowPlayerAction = Class(Action, function (self, inst, player)   
   Action._ctor(self, inst, 'FollowPlayerAction')
   self.player = player
   self.CLOSE_DIST = 4
   self.MED_DIST = 10
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
   --   error('WANDER INTEAD')
   --   return Wander(self.inst, target_pos, 5, {minwalktime=2, randwalktime=2.5, minwaittime=0, randwaittime=0.5})
   --end
   error('DISTANCE: '..tostring(dist_sq))
   if dist_sq < self.MED_DIST*self.MED_DIST
   and dist_sq > self.CLOSE_DIST*self.CLOSE_DIST then
      error('FOLLOW QUICKLY')
      return Follow(self.inst, self.player, 4, 6, 11, false)
   elseif dist_sq > self.MED_DIST * self.MED_DIST then
      return Follow(self.inst, self.player, 4, 6, 11, true)
   else
      -- very close to player
      return WalkRandomly(self.inst)
   end
end