require 'general-utils/table_ops'

Debug = Class(BehaviourNode, function (self, inst, fn)   
   BehaviourNode._ctor(self, 'Debug')
   self.inst = inst
   self.fn = fn
end)

function Debug:Visit()
   -- bondy
   print( 'instance is: ' .. tostring(self.inst))
   -- print('printing table ' .. tostring(self.fn))      
   -- print(tostring(self.inst.components.planholder.currentgoal))
   print(tostring(self.inst.components.planholder.actionplan))   
   -- if self.inst then
   --    print ''
   --    printt(self.inst)
   -- else
   --    print 'table is nil'
   -- end
end