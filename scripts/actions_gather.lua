ACTIONS.GATHERCOMMAND = Action(-1)

ACTIONS.GATHERCOMMAND.fn = function(act)
   print 'in fn'
   local targ = act.target
   if act.doer.HUD and targ.components.gatherminion then
      targ.components.gatherminion:Command(act.doer)
      return true
   end   
end