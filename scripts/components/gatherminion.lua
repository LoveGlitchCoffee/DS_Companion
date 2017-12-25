local GatherCommandWidget = require 'widgets/gathercommandwidget'

GatherMinion = Class(function(self, inst)
   self.inst = inst   
end)

function GatherMinion:CollectSceneActions(doer, actions)   
   -- inserting into actions is what makes it clickable.
   -- if just write function out, its hover
   table.insert(actions, ACTIONS.GATHERCOMMAND)
end

function GatherMinion:Command(doer, target)
   local controls = doer.HUD.controls
   local widget = controls.containerroot:AddChild(GatherCommandWidget(doer))
   widget:Open(target)

   if controls.containers['gathercommand'] then
      controls.containers['gathercommand']:Close()
   else      
      controls.containers['gathercommand'] = nil
   end
   
   controls.containers['gathercommand'] = widget
end


return GatherMinion