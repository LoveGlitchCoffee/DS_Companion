require "brains/selectgoal"
require "brains/planactions"
require "brains/qlearner"
require "behaviours/closurechattynode"
require "generalutils/table_ops"
require "generalutils/debugprint"

---
-- Root type BT node for GOAP for this mod. Used instead of normal Behaviour Tree nodes
-- Similar to Sequence Node but with difference that it does not have a SUCCESS state,
-- this allows for looping, which is similar to Priority Node
-- @param period Period of each visit of node
-- @param gwulistfn Function that returns the weighted goal list (explained in Visit())
-- @param inst Instance for GOAP
-- @class ResponsiveGOAPNode
-- @see brains/planactions.populate_actions
-- @see brains/qlearner.populateallmatrices
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
   self.announcegoal = nil

   -- populate actions
   populate_actions(inst)
   -- populate q-learning matrices
   populateallmatrices(ALL_ACTIONS)

   -- on change in health level update q-learning appropriately
   self.onHealthChange = function(inst, data)
      if not self.oldgoal or self.plan then
         return
      end

      local changedegree = math.abs( data.oldpercent - data.newpercent )

      if data.oldpercent > data.newpercent then
         -- losing health
         if changedegree > 0.2 then
            updaterewardmatrix(self.oldgoal.name, self.plan[self.idx].name, -5)
         else
            updaterewardmatrix(self.oldgoal.name, self.plan[self.idx].name, -10)
         end
      else
         -- gaining health
         if changedegree > 0.3 then
            updaterewardmatrix(self.oldgoal.name, self.plan[self.idx].name, 4)
         else
            updaterewardmatrix(self.oldgoal.name, self.plan[self.idx].name, 3)
         end
      end
   end

   self.inst:ListenForEvent('healthdelta', self.onHealthChange)
end)

-- should have on stop

function ResponsiveGOAPNode:DBString()
   return tostring(self.idx)
end

function ResponsiveGOAPNode:Reset()
   self._base.Reset(self)
   self.idx = 1
end

---
-- From current STRIPS action plan, generate the appropriate behaviour sequence as a tablle
-- behaviour sequence returned from action:Perform()
-- @return table of behaviour sequence
function ResponsiveGOAPNode:generateActionSequence()
   if self.plan == nil then
      return nil
   end

   local actionsequence = {}
   for a = 1, #self.plan do
      info(tostring(self.plan[a]))
      table.insert(actionsequence, #actionsequence + 1, self.plan[a]:Perform())
   end
   return actionsequence
end

---
-- Visiting node constitutes the following, executes only when time for evaluation:
-- 1. Execute any chatting for announcing goals
-- 2. Select a new goal if appropriate
-- 3. If new goal is not the same as previous, priorities has changed,
-- come up with plan to pursue new goal
-- 4. Announce going to pursue new goal
-- 5. Similar to SequenceNode, loop through each behaviour in plan an execute them until SUCCESS or FAIL
-- Success leads to executing next action in plan
-- Fail leads to termination of current sequence of action for re-planning next iteration
-- Whether success or failure, update q-learning with experience
function ResponsiveGOAPNode:Visit()   
   -- Announce goal
   if self.announcegoal then      
      self.announcegoal:Visit()
      if self.announcegoal.status == SUCCESS then
         self.announcegoal = nil
      end
      return
   end

   local time = GetTime()
   local do_eval = not self.lasttime or not self.period or self.lasttime + self.period < time

   if do_eval then

      self.lasttime = time
      -- reset if finish sequence of action, or failed it
      if self.finish then
         info("RESETINNG")
         self.oldgoal = nil
         self.finish = false
      end

      -- select goal
      local newgoal = selectgoal(self.gwulistfn)

      info(tostring(not self.oldgoal))
      info(tostring(not self.oldgoal == newgoal))
      local replan = not self.oldgoal or (newgoal and not self.oldgoal == newgoal)

      if replan then
         info("HAVING TO REPLAN")
         self.oldgoal = newgoal
         error('new goal: '..tostring(newgoal))

         -- reset all actions for good measure
         -- even though perform makes anew one each time, could store them
         if self.actionplan then
            for idx, child in ipairs(self.actionplan) do
               child:Reset()
            end
         end

         -- new plan
         self.plan = planactions(self.inst, newgoal)
         print('.\n')
         printt(self.plan)
         self.actionplan = self:generateActionSequence()
         -- reset index
         self.idx = 1
      end
      
      -- announce goal if new one
      if newgoal:Announce() and replan then         
         self.announcegoal = ClosureChattyNode(self.inst, {newgoal:Announce()}, 1)         
         self.inst.components.locomotor:Stop()
         return
      end

      -- same as Visit for SequenceNode
      if self.actionplan then         
         while self.idx <= #self.actionplan do            
            local child = self.actionplan[self.idx]
            child:Visit()
            info("child: " .. tostring(child.name) .. ". status: " .. tostring(child.status))
            if child.status == RUNNING then
               self.status = child.status
               return

            elseif child.status == FAILED then
               -- push 'failreasoning' for Follow action to have something to talk about
               self.finish = true
               self.inst:PushEvent('failreasoning', {reason=self.plan[self.idx]:FailReason()})
               error("FAILED. REPLAN")
               for i=self.idx, #self.actionplan do
                  -- all future action fails
                  updaterewardmatrix(self.oldgoal.name, self.plan[i].name, -10)
               end
               return
            end

            -- if child succeeds
            info("child suceed, move on")
            self.idx = self.idx + 1

            -- update qlearner
            if self.idx <= #self.actionplan then
               updaterewardmatrix(self.oldgoal.name, self.plan[self.idx].name, 7)
            end
         end

         error("FINISH Sequence")
         self.finish = true
         updaterewardmatrix(self.oldgoal.name, self.plan[self.idx - 1].name, 10) -- update for previous
      else

         error("No plan")
      end
   else
      error("doing this instead")
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
