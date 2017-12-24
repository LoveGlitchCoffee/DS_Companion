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
   print 'adding child for gather'
   widget = doer.HUD.controls.containerroot:AddChild(GatherCommandWidget(doer))
   print('added to player ase')
   widget:Open(target)
end


return GatherMinion