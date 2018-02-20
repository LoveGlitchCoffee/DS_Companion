require "goals/goal"
require "generalutils/debugprint"
require "generalutils/config"

---
-- Goal of getting item for player
-- @param inst Instance to get the item
-- @param item item to get
-- @class GetForPlayer
GetForPlayer = Class(Goal, function(self, inst, item)
   Goal._ctor(self, inst, "GetForPlayer"..item, "I'll BRING THAT TO YOU")
   self.item = item
   self.urgency = GET_FOR_PLAYER_U
   self.cur_time = GetTime()
   self.unlocked = false

   self.unlockSelf = function (inst, data)
      if data.goal == self then         
         self.unlocked = true
      end
   end
   -- callback function to update the urgency value of goal
   self.updateUrgency = function(inst, data)
      if not self.unlocked then
         return
      end
      -- update after certain amount of time has passed
      if GetTime() - self.cur_time > GET_FOR_PLAYER_TIME_THRES then
         self.urgency = self.urgency - GET_FOR_PLAYER_U_DECREASE -- decrease urgency
         self.cur_time = GetTime()
         info('updating urgency '..tostring(self.urgency)..' of '..self.name)
         if self.urgency <= 0 then
            -- drop it if not urgent anymore
            self.inst:PushEvent('dropgoal', {goalname=self.name})
            -- not sure if follow will remove ref and hence prevent memory leak
         end
      end
   end

   -- callback to drop all callbacks if this goal was dropped
   self.dropSelf = function (inst, data)
      if data.goalname == self.name then         
         self.unlocked = false
      end
   end

   self.inst:ListenForEvent('insertgoal', self.unlockSelf)
   self.inst:ListenForEvent('clocktick', self.updateUrgency)
   self.inst:ListenForEvent('dropgoal', self.dropSelf) -- self callback event
   -- need to tell player its lost interest (maybe in debug for now)
end)

---
-- Satisfaction of goal, fixed value
-- @return satisfaction of getting item for player
function GetForPlayer:Satisfaction()
   -- if middle of fight, reduce?
   -- if doing something else more important reduce?
   return GET_FOR_PLAYER_S -- to make primary objective, very high value
end

---
-- Get the STRIPS precondition for completing this goal
-- haveing gave the item to the player
-- @return precondition of gave_item as table
function GetForPlayer:GetGoalState()
   local state = {}
   local key = 'gave_'..self.item
   state[key] = true
	return state
end