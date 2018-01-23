require("general-utils/debugprint")
require("brains/selectgoal") -- migh wanna place this somewhere else
require("brains/planactions")
require("general-utils/table_ops")

require "actions/gather"
require "actions/gatherfood"
require "actions/build"
require "actions/searchfor"
require "actions/eat"
require "actions/give"
require("actions/followplayeraction")
require "actions/givefood"
require("brains/qlearner")

ResponsiveGOAPNode = Class(BehaviourNode, function(self, inst, period, gwulistfn)
   BehaviourNode._ctor(self, "GOAP")
   self.idx = 1
   self.inst = inst
   self.oldgoal = nil
   self.plan = nil
   self.actionplan = nil
   self.period = period
   self.gwulistfn = gwulistfn
   self.finish = false
   self.lasttime = nil
   populate_actions(inst)
   populateallmatrices(ALL_ACTIONS) -- refactor later

   self.onHealthChange = function(inst, data)
      if not self.oldgoal or self.plan then
         return
      end

      local changedegree = math.abs( data.oldpercent - data.newpercent )

      if data.oldpercent > data.newpercent then
         if changedegree > 0.2 then
            updaterewardmatrix(self.oldgoal.name, self.plan[self.idx].name, 5)
         else
            updaterewardmatrix(self.oldgoal.name, self.plan[self.idx].name, 10)
         end         
      else
         if changedegree > 0.3 then
            updaterewardmatrix(self.oldgoal.name, self.plan[self.idx].name, 40)
         else
            updaterewardmatrix(self.oldgoal.name, self.plan[self.idx].name, 30)
         end
      end   
   end

   self.inst:ListenForEvent('healthdelta', self.onHealthChange)
end)

function ResponsiveGOAPNode:DBString()
   return tostring(self.idx)
end

function ResponsiveGOAPNode:Reset()
   self._base.Reset(self)
   self.idx = 1
end

function ResponsiveGOAPNode:Stop()
   self.inst:RemoveEventCallback('healthdelta', onHealthChange)
   BehaviourNode.Stop()   
end

function ResponsiveGOAPNode:generateActionSequence()
   if self.plan == nil then
      return nil
   end

   local actionsequence = {}
   for a = 1, #self.plan do
      table.insert(actionsequence, #actionsequence + 1, self.plan[a]:Perform())
   end
   return actionsequence
end

function ResponsiveGOAPNode:Visit()
   local time = GetTime()
   local do_eval = not self.lasttime or not self.period or self.lasttime + self.period < time

   if do_eval then
      self.lasttime = time
      if self.finish then
         info("RESETINNG")
         self.oldgoal = nil
         self.finish = false
      end

      -- select goal
      local newgoal = selectgoal(self.gwulistfn)
      -- info('new goal: '..tostring(newgoal))
      -- info(tostring(not self.oldgoal))
      -- info(tostring(not self.oldgoal == newgoal))
      local replan = not self.oldgoal or (newgoal and not self.oldgoal == newgoal)

      if replan then
         info("HAVING TO REPLAN")
         self.oldgoal = newgoal
         -- reset all actions for good measure
         -- even though perform makes anew one each time, could store them
         if self.actionplan then
            for idx, child in ipairs(self.actionplan) do
               child:Reset()
            end
         end
         -- new plan
         self.plan = planactions(self.inst, newgoal)
         printt(self.plan)
         self.actionplan = self:generateActionSequence()
         -- reset idx
         self.idx = 1
      end

      if self.actionplan then
         while self.idx <= #self.actionplan do
            local child = self.actionplan[self.idx]
            child:Visit()
            info("child: " .. tostring(child.name) .. ". status: " .. tostring(child.status))
            if child.status == RUNNING then
               self.status = child.status
               return
            elseif child.status == FAILED then
               self.finish = true
               error("FAILED. REPLAN")
               updaterewardmatrix(self.oldgoal.name, self.plan[self.idx].name, 20)
               return
            end
            -- if child succeeds
            info("child suceed, move on")
            self.idx = self.idx + 1
            -- update qlearner
            if self.idx <= #self.actionplan then
               updaterewardmatrix(self.oldgoal.name, self.plan[self.idx].name, 70)
            end
         end
         info("FINISH Sequence")
         self.finish = true
         updaterewardmatrix(self.oldgoal.name, self.plan[self.idx - 1].name, 100) -- update for previous
      --self.status = SUCCESS
      end
   else
      if self.idx then
         local child = self.actionplan[self.idx]
         if child then
            child:Visit()
         end
         if self.status ~= RUNNING then
            self.lasttime = nil
         end
      end
   end
end
