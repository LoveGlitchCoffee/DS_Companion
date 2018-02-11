local GatherCommandWidget = require "widgets/gathercommandwidget"

---
-- Component to allow a character to gather items, making them a gather minio
-- @param inst Instance to be the minion
-- @class GatherMinion
GatherMinion = Class(function(self, inst)
   self.inst = inst
end)

---
-- Clicking triggers the Gather command
-- @param doer the character making the commands
-- @param actions the table of actions
function GatherMinion:CollectSceneActions(doer, actions)
   -- inserting into actions is what makes it clickable.
   -- if just write function out, its hover
   table.insert(actions, ACTIONS.GATHERCOMMAND)
end

---
-- Creates and open the Gather Command Widget
-- @param doer the character giving the commands
-- @param target the targetted character that will receive commands
-- @see widgets/gathercommandwidget.GatherCommandWidget
function GatherMinion:Command(doer, target)
   local controls = doer.HUD.controls
   local widget = controls.containerroot:AddChild(GatherCommandWidget(doer, self.inst))
   widget:Open(target)

   if controls.containers['gathercommand'] then
      controls.containers['gathercommand']:Close()
   else
      controls.containers['gathercommand'] = nil
   end

   controls.containers['gathercommand'] = widget
end


return GatherMinion