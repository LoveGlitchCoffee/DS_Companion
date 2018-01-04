require("general-utils/debugprint")
require("behaviours/selectgoal") -- migh wanna place this somewhere else
require("behaviours/planactions")

require 'actions/gather'
require 'actions/gatherfood'
require 'actions/build'
require 'actions/searchfor'
require 'actions/eat'
require 'actions/give'
require("actions/followplayeraction")
require 'actions/givefood'

GOAPPriorityNode = Class(BehaviourNode, function(self, planfn, period)
    BehaviourNode._ctor(self, "GOAPPriority")
    self.period = period or 1
    self.planfn = planfn
end)

function GOAPPriorityNode:GetSleepTime()
    if self.status == RUNNING then
        if not self.period then
            return 0
        end


        local time_to = 0
        if self.lasttime then
            time_to = self.lasttime + self.period - GetTime()
            if time_to < 0 then
                time_to = 0
            end
        end

        return time_to
    elseif self.status == READY then
        return 0
    end

    return nil

end


function GOAPPriorityNode:DBString()
    local time_till = 0
    if self.period then
       time_till = (self.lasttime or 0) + self.period - GetTime()
    end

    return string.format("execute %d, eval in %2.2f", self.idx or -1, time_till)
end


function GOAPPriorityNode:Reset()
    self._base.Reset(self)
    self.idx = nil
end

function GOAPPriorityNode:Visit()
    -- dun give a shit if each child fail.
    -- only change this status is success or running
    local time = GetTime()
    local do_eval = not self.lasttime or not self.period or self.lasttime + self.period < time

    local plan = self.planfn()
    if do_eval then
        self.lasttime = time
        local found = false
        error('current idx: '..tostring(self.idx))
        for idx, child in ipairs(plan) do

            if not found then

                if child.status == FAILED or child.status == SUCCESS then
                    child:Reset() -- if alread finish then do them again
                end
                child:Visit()
                error('visit: '..tostring(child.name))
                local cs = child.status
                if cs == SUCCESS or cs == RUNNING then
                    self.status = cs
                    found = true
                    self.idx = idx
                end
            else
                error('skip: '..tostring(child.name))
                child:Reset()
            end
        end
        if not found then
            self.status = FAILED
        end

    else
        if self.idx then
            local child = plan[self.idx]
            if child.status == RUNNING then
                child:Visit()
                self.status = child.status
                if self.status ~= RUNNING then
                    self.lasttime = nil
                end
            end
        end
    end

end


GOAPSequenceNode = Class(BehaviourNode, function(self, planfn)
    BehaviourNode._ctor(self, "GOAPSequence")
    self.idx = 1
    self.planfn = planfn
end)

function GOAPSequenceNode:DBString()
    return tostring(self.idx)
end

function GOAPSequenceNode:Reset()
    self._base.Reset(self)
    self.idx = 1
end

function GOAPSequenceNode:Visit()

    if self.status ~= RUNNING then
        self.idx = 1
    end

    local done = false
    local plan = self.planfn() -- generate plan
    while self.idx <= #plan do
        local child = plan[self.idx]
        child:Visit()
        if child.status == RUNNING or child.status == FAILED then
            self.status = child.status
            return
        end
        self.idx = self.idx + 1
    end
    self.status = SUCCESS
end

ResponsiveGOAPNode = Class(BehaviourNode, function(self, inst, period, gwulistfn)
    BehaviourNode._ctor(self, "GOAP")
    self.idx = 1
    self.inst = inst
    self.oldgoal = nil
    self.plan = nil
    self.period = period
    self.gwulistfn = gwulistfn
    self.finish = false
    self.lasttime = nil
    populate_actions(inst)
end)

function ResponsiveGOAPNode:DBString()
    return tostring(self.idx)
end

function ResponsiveGOAPNode:Reset()
    self._base.Reset(self)
    self.idx = 1
end

function ResponsiveGOAPNode:generateActionSequence(plan)
   if plan == nil then return plan end

   local actionsequence = {}
   for a=1,#plan do
     table.insert(actionsequence, #actionsequence+1, plan[a]:Perform())
   end
   return actionsequence
end

function ResponsiveGOAPNode:Visit()

   local time = GetTime()
   local do_eval = not self.lasttime or not self.period or self.lasttime + self.period < time

   if do_eval then
      error('eval')
      self.lasttime = time
      if self.finish then
         error('RESETINNG')
         self.oldgoal = nil
         self.finish = false
      end

      -- select goal
      local newgoal = selectgoal(self.gwulistfn)
      error('new goal: '..tostring(newgoal))
      -- error(tostring(not self.oldgoal))
      -- error(tostring(not self.oldgoal == newgoal))
      local replan = not self.oldgoal or not self.oldgoal == newgoal

      if replan then
         error('HAVING TO REPLAN')
         self.oldgoal = newgoal
         -- reset all actions for good measure
         -- even though perform makes anew one each time, could store them
         if self.plan then
            for idx,child in ipairs(self.plan) do
               child:Reset()
            end
         end
         -- new plan
         local plan = planactions(self.inst, newgoal)
         self.plan = self:generateActionSequence(plan)
         -- reset idx
         self.idx = 1
      end

      if self.plan then
         while self.idx <= #self.plan do            
            local child = self.plan[self.idx]
            child:Visit()
            error('child: '..tostring(child.name)..'. status: '..tostring(child.status))
            if child.status == RUNNING then
               self.status = child.status               
               return
            elseif child.status == FAILED then
               self.finish = true
               error('FAILED< REPLAN')
               return
            end
            -- if child succeeds
            error("child suceed, move on")
            self.idx = self.idx + 1
         end
         error('FINISH Sequence')
         self.finish = true
         --self.status = SUCCESS
      end
   else
      error('not eval')
      if self.idx then
         local child = self.plan[self.idx]
         child:Visit()         
         if self.status ~= RUNNING then
            self.lasttime = nil
         end
      end
   end
end