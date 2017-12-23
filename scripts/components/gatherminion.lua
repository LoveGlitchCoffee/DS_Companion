local GatherCommandWidget = require 'widgets/gathercommandwidget'

GatherMinion = Class(function(self, inst)
   self.inst = inst   
end)

function GatherMinion:CollectSceneActions(doer, actions)      
   --table.insert(actions, actions.ACTIONS.GATHERCOMMAND)
   error('pressed')
   self.widget = GatherCommandWidget(doer)
   self.widget:Open()
end

function GatherMinion:Command(doer)   
   self.widget = GatherCommandWidget(doer)
   self.widget:Open()
end


return GatherMinion