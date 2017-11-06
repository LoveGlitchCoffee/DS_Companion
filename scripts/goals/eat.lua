require 'actions/action'

Eat = Class(Action, function (self, inst)
	       Action._ctor(self, inst, 'eat')
end)

function Eat:Precondition()
   local foodInInventory = self.inst.components.inventory:FindItems(
      function (item)
         return self.inst.components.eater:CanEat(item) and
	    item.components.edible:GetHunger(self.inst) > 0 -- when eaten by eater, reduce hunger
      end
   )   
end
   
function ()
   
end
