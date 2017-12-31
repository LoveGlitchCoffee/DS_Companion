require 'goals/goal'
require 'general-utils/timeutil'
require 'general-utils/debugprint'

GetForPlayer = Class(Goal, function(self, inst, item)
   Goal._ctor(self, inst, "GetForPlayer")
   self.item = item
   self.name = (self.name .. self.item)
   self.urgency = 0.8 -- pretty high urgency, usually primary task
   self.cur_time = os.clock()
   self.time_thres = 5 -- in seconds

   self.updateUrgency = function(inst, data)      
      if os.clock() - self.cur_time > self.time_thres then
         self.urgency = self.urgency - 0.1
         self.cur_time = os.clock()
         error('updating urgency'..tostring(self.urgency))
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
   return 0.8 -- to make primary objective, very high value
end

function GetForPlayer:GetGoalState()
   local state = {}
   local key = 'giving_'..self.item
   state[key] = true      
	return state
end