require("general-utils/debugprint")
require("behaviours/selectgoal") -- migh wanna place this somewhere else
require("behaviours/planactions")
require("general-utils/table_ops")

require 'actions/gather'
require 'actions/gatherfood'
require 'actions/build'
require 'actions/searchfor'
require 'actions/eat'
require 'actions/give'
require("actions/followplayeraction")
require 'actions/givefood'

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
      self.lasttime = time
      if self.finish then
         info('RESETINNG')
         self.oldgoal = nil
         self.finish = false
      end

      -- select goal
      local newgoal = selectgoal(self.gwulistfn)
      -- info('new goal: '..tostring(newgoal))
      -- info(tostring(not self.oldgoal))
      -- info(tostring(not self.oldgoal == newgoal))
      local replan = not self.oldgoal or not self.oldgoal == newgoal

      if replan then
         info('HAVING TO REPLAN')
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
         printt(plan)
         self.plan = self:generateActionSequence(plan)
         -- reset idx
         self.idx = 1
      end

      if self.plan then
         while self.idx <= #self.plan do            
            local child = self.plan[self.idx]
            child:Visit()
            info('child: '..tostring(child.name)..'. status: '..tostring(child.status))
            if child.status == RUNNING then
               self.status = child.status               
               return
            elseif child.status == FAILED then
               self.finish = true
               error('FAILED. REPLAN')
               return
            end
            -- if child succeeds
            info("child suceed, move on")
            self.idx = self.idx + 1
         end
         info('FINISH Sequence')
         self.finish = true
         --self.status = SUCCESS
      end
   else      
      if self.idx then
         local child = self.plan[self.idx]
         if child then
            child:Visit()
         end
         if self.status ~= RUNNING then
            self.lasttime = nil
         end
      end
   end
end