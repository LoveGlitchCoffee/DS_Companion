require 'goals/goal'
require 'general-utils/debugprint'
require("general-utils/config")

GetForPlayer = Class(Goal, function(self, inst, item)
   Goal._ctor(self, inst, "GetForPlayer"..item, "I'll BRING THAT TO YOU")
   self.item = item   
   self.urgency = GET_FOR_PLAYER_U
   self.cur_time = GetTime()   

   self.updateUrgency = function(inst, data)      
      if GetTime() - self.cur_time > GET_FOR_PLAYER_TIME_THRES then
         self.urgency = self.urgency - GET_FOR_PLAYER_U_DECREASE
         self.cur_time = GetTime()
         info('updating urgency '..tostring(self.urgency))
         if self.urgency <= 0 then
            -- drop it
            self.inst:PushEvent('dropgoal', {goalname=self.name})
            -- not sure if follow will remove ref and hence prevent memory leak            
         end
      end      
   end

   self.dropSelf = function (inst, data)
      if data.goalname == self.name then
         self.inst:RemoveEventCallback('clocktick', self.updateUrgency)
         self.inst:RemoveEventCallback('dropgoal', self.dropSelf)
      end      
   end
   
   self.inst:ListenForEvent('clocktick', self.updateUrgency)
   self.inst:ListenForEvent('dropgoal', self.dropSelf)
   -- update urgency as time goes pass, goes down
   -- over certain level remove from list
   -- maybe down satisfaction as well
   -- need to tell player its lost interest (maybe in debug for now)
end)

function GetForPlayer:Satisfaction()
   -- if middle of fight, reduce?
   -- if doing something else more important reduce?
   return GET_FOR_PLAYER_S -- to make primary objective, very high value
end

function GetForPlayer:GetGoalState()
   local state = {}
   local key = 'gave_'..self.item
   state[key] = true      
	return state
end